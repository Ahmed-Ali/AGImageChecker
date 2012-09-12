//
//  AGImageViewTests.m
//  AGImageChecker
//
//  Created by Angel on 9/4/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageViewTests.h"
#import "UIImageView+AGImageChecker.h"

@implementation AGImageViewTests

@synthesize bundle;
@synthesize squareBigImage;
@synthesize squareSmallImage;
@synthesize rectImage;
@synthesize squareBigView;
@synthesize squareSmallView;
@synthesize rectView;

- (void) setUp {
    [[UIScreen mainScreen] setValue:[NSNumber numberWithInt:1] forKey:@"scale"];
    
    [UIImageView startCheckingImages];
    self.bundle = [NSBundle bundleForClass:[self class]];
    self.squareSmallImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"square_small_image" ofType:@"png"]];
    self.squareBigImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"square_big_image" ofType:@"png"]];
    self.rectImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"rect_image" ofType:@"png"]];
    self.squareSmallView = [[UIImageView alloc] initWithImage:squareSmallImage];
    self.squareBigView = [[UIImageView alloc] initWithImage:squareBigImage];
    self.rectView = [[UIImageView alloc] initWithImage:rectImage];

}

- (void)tearDown {
    [UIImageView stopCheckingImages];    
    [[UIScreen mainScreen] setValue:[NSNumber numberWithInt:1] forKey:@"scale"];    
}

- (void)testImagesLoaded {
    STAssertNotNil(squareSmallImage, @"Small square image not loaded");
    STAssertNotNil(squareBigImage, @"Big square image not loaded");
    STAssertNotNil(rectView, @"Rect image not loaded");
}

- (void)testCorrectImageSizeGivesNoIssue {
    STAssertTrue(squareSmallView.issues == AGImageCheckerIssueNone, @"The default small square image should not return issues");    
    STAssertTrue(squareBigView.issues == AGImageCheckerIssueNone, @"The default big square image  should not return issues");    
    STAssertTrue(rectView.issues == AGImageCheckerIssueNone, @"The default rect image  should not return issues");    
}

- (void)testIssuesHandlerCalled {
    __block BOOL called = NO;
    [UIImageView setImageIssuesHandler:^(UIImageView *imageView, AGImageCheckerIssue issues) {
        called = YES;
    }];    
    squareBigView.image = squareSmallImage;
    STAssertTrue(called, @"The drawing code should have been called when setting the image");        
    
    called = NO;
    squareBigView.contentMode = UIViewContentModeTop;
    STAssertTrue(called, @"The drawing code should have been called when setting the contentMode");        
    
    called = NO;
    squareBigView.frame = squareSmallView.frame;
    STAssertTrue(called, @"The drawing code should have been called when setting the frame");        
}

- (void)testDecodingImageGivesNoIssue {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:squareBigView];
    UIImageView *restoredImageView = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    STAssertNotNil(restoredImageView, @"The restored image should be loaded");
    STAssertTrue(restoredImageView.issues == AGImageCheckerIssueNone, @"The restored image should have no issues");
}

- (void)testRectImageSizeGivesNoIssueForAllContentModes {
    rectView.contentMode = UIViewContentModeScaleAspectFill;
    STAssertTrue(rectView.issues == AGImageCheckerIssueNone, @"The rect image in mode ScaleAspectFill should not return issues");
    
    rectView.contentMode = UIViewContentModeScaleAspectFit;
    STAssertTrue(rectView.issues == AGImageCheckerIssueNone, @"The rect image in mode ScaleAspectFit should not return issues");
    
    rectView.contentMode = UIViewContentModeScaleToFill;
    STAssertTrue(rectView.issues == AGImageCheckerIssueNone, @"The rect image in mode ScaleToFill should not return issues");
    
    rectView.contentMode = UIViewContentModeCenter; 
    STAssertTrue(rectView.issues == AGImageCheckerIssueNone, @"The rect image in mode Center should not return issues");    
}

- (void)testImagesWithModeScaleAspectFill {
    rectView.contentMode = UIViewContentModeScaleAspectFill;
    squareBigView.contentMode = UIViewContentModeScaleAspectFill;
    squareSmallView.contentMode = UIViewContentModeScaleAspectFill;
    
    rectView.image = squareBigImage;
    STAssertTrue(rectView.issues == (AGImageCheckerIssueResized | AGImageCheckerIssuePartiallyHidden), @"The rect view with a big image should have issues Resized and PartiallyHidden");
    
    rectView.image = squareSmallImage;
    STAssertTrue(rectView.issues == (AGImageCheckerIssueResized | AGImageCheckerIssueBlurry | AGImageCheckerIssuePartiallyHidden), @"The rect view with a small image should have issues Resized, Blurry and PartiallyHidden");

    squareSmallView.image = squareBigImage;
    STAssertTrue(squareSmallView.issues == (AGImageCheckerIssueResized), @"The small view with a big image should have issues Resized");

    squareBigView.image = squareSmallImage;
    STAssertTrue(squareBigView.issues == (AGImageCheckerIssueResized | AGImageCheckerIssueBlurry), @"The big view with a small image should have issues Resized and Blurry");
}

- (void)testImagesWithModeScaleAspectFit {
    rectView.contentMode = UIViewContentModeScaleAspectFit;
    squareBigView.contentMode = UIViewContentModeScaleAspectFit;
    squareSmallView.contentMode = UIViewContentModeScaleAspectFit;
    
    rectView.image = squareBigImage;
    STAssertTrue(rectView.issues == (AGImageCheckerIssueResized), @"The rect view with a big image should have issues Resized");
    
    rectView.image = squareSmallImage;
    STAssertTrue(rectView.issues == (AGImageCheckerIssueResized | AGImageCheckerIssueBlurry), @"The rect view with a small image should have issues Resized and Blurry");
    
    squareSmallView.image = squareBigImage;
    STAssertTrue(squareSmallView.issues == (AGImageCheckerIssueResized), @"The small view with a big image should have issues Resized");
    
    squareBigView.image = squareSmallImage;
    STAssertTrue(squareBigView.issues == (AGImageCheckerIssueResized | AGImageCheckerIssueBlurry), @"The big view with a small image should have issues Resized and Blurry");
}

- (void)testImagesWithModeScaleToFill {
    rectView.contentMode = UIViewContentModeScaleToFill;
    squareBigView.contentMode = UIViewContentModeScaleToFill;
    squareSmallView.contentMode = UIViewContentModeScaleToFill;
    
    rectView.image = squareBigImage;
    STAssertTrue(rectView.issues == (AGImageCheckerIssueResized | AGImageCheckerIssueStretched), @"The rect view with a big image should have issues Resized and Stretched");
    
    rectView.image = squareSmallImage;
    STAssertTrue(rectView.issues == (AGImageCheckerIssueResized | AGImageCheckerIssueBlurry | AGImageCheckerIssueStretched), @"The rect view with a small image should have issues Resized, Blurry and Stretched");
    
    squareSmallView.image = squareBigImage;
    STAssertTrue(squareSmallView.issues == (AGImageCheckerIssueResized), @"The small view with a big image should have issues Resized");
    
    squareBigView.image = squareSmallImage;
    STAssertTrue(squareBigView.issues == (AGImageCheckerIssueResized | AGImageCheckerIssueBlurry), @"The big view with a small image should have issues Resized and Blurry");
}


- (void)testImagesWithModeOthers {
    //UIViewContentModeBottom, UIViewContentModeBottomLeft,... are equivalent to UIViewContentModeCenter regarding issues
    rectView.contentMode = UIViewContentModeCenter;
    squareBigView.contentMode = UIViewContentModeCenter;
    squareSmallView.contentMode = UIViewContentModeCenter;
    
    rectView.image = squareBigImage;
    STAssertTrue(rectView.issues == (AGImageCheckerIssuePartiallyHidden), @"The rect view with a big image should have issues PartiallyHidden");
    
    rectView.image = squareSmallImage;
    STAssertTrue(rectView.issues == (AGImageCheckerIssueNone), @"The rect view with a small image should have no issues");
    
    squareSmallView.image = squareBigImage;
    STAssertTrue(squareSmallView.issues == (AGImageCheckerIssuePartiallyHidden), @"The small view with a big image should have issues PartiallyHidden");
    
    squareBigView.image = squareSmallImage;
    STAssertTrue(squareBigView.issues == (AGImageCheckerIssueNone), @"The big view with a small image should have no issues");
}

- (void)testImagesWithModeCenterAndMissaligned {
    //When setting to center the image can be aligned to 0.5. Check it returns blurry
    squareBigView.contentMode = UIViewContentModeCenter;
    CGRect frame = squareBigView.frame;
    frame.size.width += 1;
    squareBigView.frame = frame;    
    STAssertTrue(squareBigView.issues == (AGImageCheckerIssueBlurry | AGImageCheckerIssueMissaligned), @"The image center into a .5 x should be blurry and missaligned");

    frame.size.width -= 1;
    frame.size.height += 1;
    squareBigView.frame = frame;    
    STAssertTrue(squareBigView.issues == (AGImageCheckerIssueBlurry | AGImageCheckerIssueMissaligned), @"The image center into a .5 y should be blurry and missaligned");            
}

- (void)testChangeFrameProducesIssues {
    squareBigView.frame = squareSmallView.frame;
    STAssertTrue(squareBigView.issues != (AGImageCheckerIssueNone), @"The change of frame should produce issues");    
}

- (void)testChangeContentModeProducesIssues {
    squareBigView.contentMode = UIViewContentModeTop;
    squareBigView.image = squareSmallImage;
    STAssertTrue(squareBigView.issues == (AGImageCheckerIssueNone), @"The big image on mode top should not have issues displaying the small image");    
    
    squareBigView.contentMode = UIViewContentModeScaleToFill;
    STAssertTrue(squareBigView.issues != (AGImageCheckerIssueNone), @"The big image on mode fill should have issues displaying the small image");    
}

- (void)testStretchableImageProducesNoIssue {
    squareBigView.contentMode = UIViewContentModeScaleToFill;
    squareBigView.image = [rectImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    STAssertTrue(squareBigView.issues == (AGImageCheckerIssueNone), @"The big image on mode fill should have no issues displaying a resizable image");        
}

- (void)testMissingImageProducesIssue {
    squareBigView.image = nil;
    STAssertTrue(squareBigView.issues == (AGImageCheckerIssueMissing), @"A nil image should have issue Missing");        
}

- (void)testRetinaDisplayProducesIssueInNonRetinaImages {
    [[UIScreen mainScreen] setValue:[NSNumber numberWithInt:2] forKey:@"scale"];
    squareBigView.contentMode = UIViewContentModeScaleAspectFit;
    STAssertTrue(squareBigView.issues == (AGImageCheckerIssueResized | AGImageCheckerIssueBlurry), @"The image in retina should have issues Resized and Blurry");        
}

- (void)testRetinaDisplayWorksWithNonRetinaImageButDouble {
    [[UIScreen mainScreen] setValue:[NSNumber numberWithInt:2] forKey:@"scale"];
    squareBigView.contentMode = UIViewContentModeScaleAspectFit;
    squareBigView.image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"square_big_image_2x" ofType:@"png"]];
    STAssertNotNil(squareBigView.image, @"Retina image could not be loaded");
    STAssertTrue(squareBigView.issues == (AGImageCheckerIssueNone), @"The image with the correct retina asset should have no issues");        
}

- (void)testRetinaDisplayWorksWithRetinaImage {
    [[UIScreen mainScreen] setValue:[NSNumber numberWithInt:2] forKey:@"scale"];
    squareBigView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *img = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"square_big_image_2x" ofType:@"png"]];
    [img setValue:[NSNumber numberWithInt:2] forKey:@"scale"];
    squareBigView.image = img;
    STAssertNotNil(squareBigView.image, @"Retina image could not be loaded");
    STAssertTrue(squareBigView.issues == (AGImageCheckerIssueNone), @"The image with the correct retina asset should have no issues");            
}

- (void)testImageMissalignedProducesIssues {
    CGRect frame = squareBigView.frame;
    frame.origin.x += 0.5;
    squareBigView.frame = frame;    
    STAssertTrue(squareBigView.issues == (AGImageCheckerIssueBlurry | AGImageCheckerIssueMissaligned), @"The image postioned in .5 x should be blurry and missaligned"); 

    frame.origin.x -= 0.5;
    frame.origin.y += 0.5;
    squareBigView.frame = frame;    
    STAssertTrue(squareBigView.issues == (AGImageCheckerIssueBlurry | AGImageCheckerIssueMissaligned), @"The image postioned in .5 y should be blurry and missaligned");    
}

- (void)testFatherMissalignedProducesIssues {
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    UIView *parentView = [[UIView alloc] initWithFrame:CGRectMake(0.5, 0, 300, 300)];
    [parentView addSubview:squareBigView];
    [topView addSubview:parentView];
    [squareBigView checkImage];
    STAssertTrue(squareBigView.issues == (AGImageCheckerIssueBlurry | AGImageCheckerIssueMissaligned), @"The image into a parent missaligned should be blurry and missaligned");    
}

@end
