/*
 File: AVCamViewController.m
 Abstract: View controller for camera interface.
 Version: 3.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "CameraViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

#import "AVCamPreviewView.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface CameraViewController () <AVCaptureFileOutputRecordingDelegate>

// For use in the storyboards.
@property (nonatomic, weak) IBOutlet AVCamPreviewView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (nonatomic, weak) IBOutlet UIButton *stillButton;

- (IBAction)toggleMovieRecording:(id)sender;
- (IBAction)changeCamera:(id)sender;
- (IBAction)snapStillImage:(id)sender;
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

@end

@implementation CameraViewController{


    BOOL flashon ;

}

@synthesize locationManager, startLocation, currntLocation;
@synthesize image;
@synthesize commentTextField;
@synthesize photoFile;
@synthesize thumbnailFile;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;

- (BOOL)isSessionRunningAndDeviceAuthorized
{
	return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
	return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	
	// Create the AVCaptureSession
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	[self setSession:session];
	self.previewView.frame=CGRectMake(0, 0, 320, 350);
	// Setup the preview view
	[[self previewView] setSession:session];
	
	// Check for device authorization
	[self checkDeviceAuthorizationStatus];

    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    //    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    self.startLocation = nil;

    
	// In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
	// Why not do all of this on the main queue?
	// -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
	
	dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
	[self setSessionQueue:sessionQueue];
	
	dispatch_async(sessionQueue, ^{
		[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
		
		NSError *error = nil;
		
		AVCaptureDevice *videoDevice = [CameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		
		if (error)
		{
			NSLog(@"%@", error);
		}
		
		if ([session canAddInput:videoDeviceInput])
		{
			[session addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
            
			dispatch_async(dispatch_get_main_queue(), ^{
				// Why are we dispatching this to the main queue?
				// Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
				// Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
				[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
			});
		}
		
		AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
		AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
		
		if (error)
		{
			NSLog(@"%@", error);
		}
		
		if ([session canAddInput:audioDeviceInput])
		{
			[session addInput:audioDeviceInput];
		}
		
		AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
		if ([session canAddOutput:movieFileOutput])
		{
			[session addOutput:movieFileOutput];
			AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
			if ([connection isVideoStabilizationSupported])
				[connection setEnablesVideoStabilizationWhenAvailable:YES];
			[self setMovieFileOutput:movieFileOutput];
		}
		
		AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
		if ([session canAddOutput:stillImageOutput])
		{
			[stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
			[session addOutput:stillImageOutput];
			[self setStillImageOutput:stillImageOutput];
		}
	});
}

- (void)viewWillAppear:(BOOL)animated
{
	dispatch_async([self sessionQueue], ^{
		[self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
		[self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
		[self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		
		__weak CameraViewController *weakSelf = self;
		[self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
			CameraViewController *strongSelf = weakSelf;
			dispatch_async([strongSelf sessionQueue], ^{
				// Manually restarting the session since it must have been stopped due to an error.
				[[strongSelf session] startRunning];
				[[strongSelf recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
			});
		}]];
		[[self session] startRunning];
	});
}

- (void)viewDidDisappear:(BOOL)animated
{
	dispatch_async([self sessionQueue], ^{
		[[self session] stopRunning];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		[[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
		
		[self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
		[self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
		[self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
	});
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (BOOL)shouldAutorotate
{
	// Disable autorotation of the interface when recording is in progress.
	return ![self lockInterfaceRotation];
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CapturingStillImageContext)
	{
		BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
		
		if (isCapturingStillImage)
		{
			[self runStillImageCaptureAnimation];
		}
	}
	else if (context == RecordingContext)
	{
		BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (isRecording)
			{
				[[self cameraButton] setEnabled:NO];
				//[[self recordButton] setTitle:NSLocalizedString(@"Stop", @"Recording button stop title") forState:UIControlStateNormal];
				[[self recordButton] setEnabled:YES];
			}
			else
			{
				[[self cameraButton] setEnabled:YES];
				[[self recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
				[[self recordButton] setEnabled:YES];
			}
		});
	}
	else if (context == SessionRunningAndDeviceAuthorizedContext)
	{
		BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (isRunning)
			{
				[[self cameraButton] setEnabled:YES];
				[[self recordButton] setEnabled:YES];
				[[self stillButton] setEnabled:YES];
			}
			else
			{
				[[self cameraButton] setEnabled:NO];
				[[self recordButton] setEnabled:NO];
				[[self stillButton] setEnabled:NO];
			}
		});
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark Actions

- (IBAction)toggleMovieRecording:(id)sender
{
    
    if (!flashon) {
        
        [CameraViewController setFlashMode:AVCaptureFlashModeOn forDevice:[[self videoDeviceInput] device]];
        
        flashon = YES;
        
        
    }
    
    else
    
    {
    
    [CameraViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
    
        flashon = NO;
        
    }
    
//	[[self recordButton] setEnabled:NO];
//	
//	dispatch_async([self sessionQueue], ^{
//		if (![[self movieFileOutput] isRecording])
//		{
//			[self setLockInterfaceRotation:YES];
//			
//			if ([[UIDevice currentDevice] isMultitaskingSupported])
//			{
//				// Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
//				[self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
//			}
//			
//			// Update the orientation on the movie file output video connection before starting recording.
//			[[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
//			
//			// Turning OFF flash for video recording
//			[CameraViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
//			
//			// Start recording to a temporary file.
//			NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
//			[[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
//		}
//		else
//		{
//			[[self movieFileOutput] stopRecording];
//		}
//	});
}

- (IBAction)changeCamera:(id)sender
{
	[[self cameraButton] setEnabled:NO];
	[[self recordButton] setEnabled:NO];
	[[self stillButton] setEnabled:NO];
	
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
		AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
		AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
		
		switch (currentPosition)
		{
			case AVCaptureDevicePositionUnspecified:
				preferredPosition = AVCaptureDevicePositionBack;
				break;
			case AVCaptureDevicePositionBack:
				preferredPosition = AVCaptureDevicePositionFront;
				break;
			case AVCaptureDevicePositionFront:
				preferredPosition = AVCaptureDevicePositionBack;
				break;
		}
		
		AVCaptureDevice *videoDevice = [CameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
		
		[[self session] beginConfiguration];
		
		[[self session] removeInput:[self videoDeviceInput]];
		if ([[self session] canAddInput:videoDeviceInput])
		{
			[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
			
			[CameraViewController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
			
			[[self session] addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
		}
		else
		{
			[[self session] addInput:[self videoDeviceInput]];
		}
		
		[[self session] commitConfiguration];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[[self cameraButton] setEnabled:YES];
			[[self recordButton] setEnabled:YES];
			[[self stillButton] setEnabled:YES];
		});
	});
}

- (IBAction)snapStillImage:(id)sender
{
	dispatch_async([self sessionQueue], ^{
		// Update the orientation on the still image output video connection before capturing.
		[[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
		
		// Flash set to Auto for Still Capture
		//[CameraViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
		
		// Capture a still image.
		[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
			
			if (imageSampleBuffer)
			{
				NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
				UIImage *stillImage = [[UIImage alloc] initWithData:imageData];
				[[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];

                if (error) {
                    NSLog(@"snap capture error %@", [error localizedDescription]);
                    return;
                }
                
                NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                
                CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageSampleBuffer, kCMAttachmentMode_ShouldPropagate);
                CFMutableDictionaryRef mutableAttachments = CFDictionaryCreateMutableCopy(NULL, 0, attachments);
                
                /*
                // Create GPS Dictionary
                NSMutableDictionary *gps = [NSMutableDictionary dictionary];
                
                CLLocation *location = <your location source here>;
                
                // GPS tag version
                [gps setObject:@"2.2.0.0" forKey:(NSString *)kCGImagePropertyGPSVersion];
                
                // Time and date must be provided as strings, not as an NSDate object
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"HH:mm:ss.SSSSSS"];
                [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSTimeStamp];
                
                // Latitude
                [gps setObject: (location.coordinate.latitude < 0) ? @"S" : @"N"
                        forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
                [gps setObject:[NSNumber numberWithDouble:fabs(location.coordinate.latitude)]
                        forKey:(NSString *)kCGImagePropertyGPSLatitude];
                
                // Longitude
                [gps setObject: (location.coordinate.longitude < 0) ? @"W" : @"E"
                        forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
                [gps setObject:[NSNumber numberWithDouble:fabs(location.coordinate.longitude)]
                        forKey:(NSString *)kCGImagePropertyGPSLongitude];
                
                // Altitude
                if (!isnan(location.altitude)){
                    // NB: many get this wrong, it is an int, not a string:
                    [gps setObject:[NSNumber numberWithInt: location.altitude >= 0 ? 0 : 1]
                            forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
                    [gps setObject:[NSNumber numberWithDouble:fabs(location.altitude)]
                            forKey:(NSString *)kCGImagePropertyGPSAltitude];
                }
                
                // Speed, must be converted from m/s to km/h
                if (location.speed >= 0){
                    [gps setObject:@"K" forKey:(NSString *)kCGImagePropertyGPSSpeedRef];
                    [gps setObject:[NSNumber numberWithDouble:location.speed*3.6] forKey:(NSString *)kCGImagePropertyGPSSpeed];
                }
                
                // Heading
                if (location.course >= 0){
                    [gps setObject:@"T" forKey:(NSString *)kCGImagePropertyGPSTrackRef];
                    [gps setObject:[NSNumber numberWithDouble:location.course] forKey:(NSString *)kCGImagePropertyGPSTrack];
                }
                
                CFDictionarySetValue(mutableAttachments, kCGImagePropertyGPSDictionary, CFBridgingRetain(gps));
                
                //         NSDictionary *ma = (__bridge NSDictionary *)(mutableAttachments);
                //         NSLog(@"photo attachments: %@", ma);
                
                [ROOTVC.library
                 writeImageDataToSavedPhotosAlbum:jpegData
                 metadata:(__bridge id)mutableAttachments
                 completionBlock:^(NSURL *assetURL, NSError *error) {
                     if (error) {
                         NSLog(@"XXX save to assets failed: %@", [error localizedDescription]);
                     } else {
                         [self processAsset:assetURL inGroup:ROOTVC.venue forMessage:savingMessage];
                     }
                 }];
                
                if (mutableAttachments)
                    CFRelease(mutableAttachments);
                if (attachments)
                    CFRelease(attachments);
                 */
                bool imageSaved = [self saveImage: stillImage];
			}
		}];
	});
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
	CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
	[self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
	CGPoint devicePoint = CGPointMake(.5, .5);
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
	if (error)
		NSLog(@"%@", error);
	
	[self setLockInterfaceRotation:NO];
	
	// Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
	UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
	[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
	
	[[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
		if (error)
			NSLog(@"%@", error);
		
		[[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
		
		if (backgroundRecordingID != UIBackgroundTaskInvalid)
			[[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
	}];
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *device = [[self videoDeviceInput] device];
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
			{
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
			{
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	});
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
//    
//	Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
//    if (!captureDeviceClass) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"您的设备没有拍照功能" delegate:nil cancelButtonTitle:NSLocalizedString(@"Sure", nil) otherButtonTitles: nil];
//        [alert show];
//        return;
//    }
    
   NSString *imgStr = @"";
    //AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    if ([device hasFlash]) {
        //        if (!sender) {//设置默认的闪光灯模式
        //            device.flashMode = AVCaptureFlashModeAuto;
        //        } else {
        if (device.flashMode == AVCaptureFlashModeOff) {
            device.flashMode = AVCaptureFlashModeOn;
            
            imgStr = @"flashing_on.png";
            
        } else if (device.flashMode == AVCaptureFlashModeOn) {
            device.flashMode = AVCaptureFlashModeAuto;
           // imgStr = @"flashing_auto.png";
            
        } else if (device.flashMode == AVCaptureFlashModeAuto) {
            device.flashMode = AVCaptureFlashModeOff;
            imgStr = @"flashing_off.png";
            
        }
        //        }
        
//        if (sender) {
//            [sender setImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
//        }
        
    }
//    else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"您的设备没有闪光灯功能" delegate:nil cancelButtonTitle:@"噢T_T" otherButtonTitles: nil];
//        [alert show];
//    }
    [device unlockForConfiguration];
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == position)
		{
			captureDevice = device;
			break;
		}
	}
	
	return captureDevice;
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[[self previewView] layer] setOpacity:0.0];
		[UIView animateWithDuration:.25 animations:^{
			[[[self previewView] layer] setOpacity:1.0];
		}];
	});
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted)
		{
			//Granted access to mediaType
			[self setDeviceAuthorized:YES];
		}
		else
		{
			//Not granted access to mediaType
			dispatch_async(dispatch_get_main_queue(), ^{
				[[[UIAlertView alloc] initWithTitle:@"AVCam!"
											message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
				[self setDeviceAuthorized:NO];
			});
		}
	}];
}


-(bool) saveImage: (UIImage*)image {
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    NSString *userName = [userDefaults stringForKey:@"userName"];

//    NSDictionary *dict = @{@"filename": userName,
//                           @"imageobj":image,
//                           @"datecreated":[NSDate date],
//                           @"locationcreated":@1000,
//                           @"noOfLikes":@0,
//                           @"noOfViews":@0,
//                           @"username":userName,
//                           @"reportedStatus":@NO
//                           };
//    [[MyDatabaseManager sharedManager] insertRecordInPicto:dict];
    [self shouldUploadImage:image];

    PFObject *pictoObject = [PFObject objectWithClassName:@"Picto"];
    [pictoObject setObject:userName forKey:@"filename"];
    [pictoObject setObject:self.photoFile forKey:@"imageobj"];
    [pictoObject setObject:[NSDate date] forKey:@"datecreated"];
    [pictoObject setObject:[NSNumber numberWithInt:1000] forKey:@"locationcreated"];
    [pictoObject setObject:[NSNumber numberWithInt:0] forKey:@"noOfLikes"];
    [pictoObject setObject:[NSNumber numberWithInt:0] forKey:@"noOfViews"];
    [pictoObject setObject:userName forKey:@"username"];
    [pictoObject setObject:@YES forKey:@"reportedStatus"];
    [pictoObject saveInBackground];
    
    
    return YES;
}


- (BOOL)shouldUploadImage:(UIImage *)anImage {
    
//    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
//    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    UIImage *resizedImage = anImage;
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    
    if (!imageData ) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithData:imageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
//            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
//            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    NSString *currentLatitude = [[NSString alloc]
                                 initWithFormat:@"%+.6f",
                                 newLocation.coordinate.latitude];
    //    self.latitude.text = currentLatitude;
    NSString *currentLongitude = [[NSString alloc]
                                  initWithFormat:@"%+.6f",
                                  newLocation.coordinate.longitude];
    //    self.longitude.text = currentLongitude;
    NSString *currentHorizontalAccuracy =
    [[NSString alloc]
     initWithFormat:@"%+.6f",
     newLocation.horizontalAccuracy];
    //    self.horizontalAccuracy.text = currentHorizontalAccuracy;
    NSString *currentAltitude = [[NSString alloc]
                                 initWithFormat:@"%+.6f",
                                 newLocation.altitude];
    //    self.altitude.text = currentAltitude;
    NSString *currentVerticalAccuracy =
    [[NSString alloc]
     initWithFormat:@"%+.6f",
     newLocation.verticalAccuracy];
    //    self.verticalAccuracy.text = currentVerticalAccuracy;
    if (self.startLocation == nil)
        self.startLocation = newLocation;
    CLLocationDistance distanceBetween = [newLocation
                                          distanceFromLocation:self.startLocation];
    //    NSString *tripString = [[NSString alloc]
    //                            initWithFormat:@"%f",
    //                            distanceBetween];
    //    self.distance.text = tripString;
  /*  [self setCurrentLocation:newLocation]; */
//    [[CurrentParametersGlobal currentParameters] setCurrentLocation:newLocation];
}


-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error {
    
}





@end
