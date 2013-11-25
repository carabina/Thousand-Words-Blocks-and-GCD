//
//  TWFiltersCollectionViewController.m
//  Thousand Words
//
//  Created by Eliot Arntz on 11/22/13.
//  Copyright (c) 2013 Code Coalition. All rights reserved.
//

#import "TWFiltersCollectionViewController.h"
#import "TWPhotoCollectionViewCell.h"
#import "Photo.h"

@interface TWFiltersCollectionViewController ()

@property (strong, nonatomic) NSMutableArray *filters;
@property (strong, nonatomic) CIContext *context;

@end

@implementation TWFiltersCollectionViewController

/* Lazy Instantiation */
-(NSMutableArray *)filters
{
    if (!_filters) _filters = [[NSMutableArray alloc] init];
    
    return _filters;
}

-(CIContext *)context
{
    if (!_context) _context = [CIContext contextWithOptions:nil];
    
    return _context;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    /* Set the filters property using the class method photo filters. To call the class method photoFilters */
    self.filters = [[[self class] photoFilters] mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers

/* Class method that returns an Array of filters */
+ (NSArray *)photoFilters
{
    CIFilter *sepia = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:nil];
    
    CIFilter *blur = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues: nil];
    
    CIFilter *colorClamp = [CIFilter filterWithName:@"CIColorClamp" keysAndValues:@"inputMaxComponents", [CIVector vectorWithX:0.9 Y:0.9 Z:0.9 W:0.9], @"inputMinComponents", [CIVector vectorWithX:0.2 Y:0.2 Z:0.2 W:0.2], nil];
    
    CIFilter *instant = [CIFilter filterWithName:@"CIPhotoEffectInstant" keysAndValues: nil];
    
    CIFilter *noir = [CIFilter filterWithName:@"CIPhotoEffectNoir" keysAndValues: nil];
    
    CIFilter *vignette = [CIFilter filterWithName:@"CIVignetteEffect" keysAndValues: nil];
    
    CIFilter *colorControls = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputSaturationKey, @0.5, nil];
    
    CIFilter *transfer = [CIFilter filterWithName:@"CIPhotoEffectTransfer" keysAndValues: nil];
    
    CIFilter *unsharpen = [CIFilter filterWithName:@"CIUnsharpMask" keysAndValues: nil];
    
    CIFilter *monochrome = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues: nil];
    
    NSArray *allFilters = @[sepia, blur, colorClamp, instant, noir, vignette, colorControls, transfer, unsharpen, monochrome];
    
    return allFilters;
}

/* Method returns a UIImage with a filter applied */
-(UIImage *)filteredImageFromImage:(UIImage *)image andFilter:(CIFilter *)filter
{
    /* Create a CIImage using the property on UIImage, CGImage. */
    CIImage *unfilteredImage = [[CIImage alloc] initWithCGImage:image.CGImage];
    
    /* Set the filter with the unfiltered CIImage for key kCIInputImageKey */
    [filter setValue:unfilteredImage forKey:kCIInputImageKey];
    /* Get the filtered image back calling the method outputImage */
    CIImage *filteredImage = [filter outputImage];
    
    /* Get the size of the image using the method extent */
    CGRect extent = [filteredImage extent];
    
    /* Create a CGImageRef using the method createCGImage with the size extent. */
    CGImageRef cgImage = [self.context createCGImage:filteredImage fromRect:extent];
    
    /* Create a UIImage from our cgImage. */
    UIImage *finalImage = [UIImage imageWithCGImage:cgImage];
    
    NSLog(@"Look at all of this data %@", UIImagePNGRepresentation(finalImage));
    
    return finalImage;
}

#pragma mark - UICollectionView DataSource

/* Setup the CollectionView cells with the UIImages with the filters applied */
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo Cell";
    
    TWPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    /* Create a queue so that we can have the filter application occur on another thread. */
    dispatch_queue_t filterQueue = dispatch_queue_create("filter queue", NULL);
    
    /* Kick off another thread using a block. Perform the filter in the block*/
    dispatch_async(filterQueue, ^{
        UIImage *filterImage = [self filteredImageFromImage:self.photo.image andFilter:self.filters[indexPath.row]];
        /* UI adjustments must occur on the main thread. */
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = filterImage;
        });
    });
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.filters count];
}

#pragma mark - UICollectionView Delegate

/* When the user selects one of the filters save the image with the filter. */
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TWPhotoCollectionViewCell *selectedCell = (TWPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    self.photo.image = selectedCell.imageView.image;
    
    /* Make sure that cell has a filter before we allow the user to select the cell. */
    if (self.photo.image){
        
        NSError *error = nil;
        
        if (![[self.photo managedObjectContext] save:&error]){
            //Handle Error
            NSLog(@"%@", error);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
