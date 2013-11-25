//
//  TWPhotosCollectionViewController.m
//  Thousand Words
//
//  Created by Eliot Arntz on 11/14/13.
//  Copyright (c) 2013 Code Coalition. All rights reserved.
//

#import "TWPhotosCollectionViewController.h"
#import "TWPhotoCollectionViewCell.h"
#import "Photo.h"
#import "TWPictureDataTransformer.h"
#import "TWCoreDataHelper.h"
#import "TWPhotoDetailViewController.h"

@interface TWPhotosCollectionViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray *photos; // Of UIImages

@end

@implementation TWPhotosCollectionViewController

/* Lazy Instantiation */
- (NSMutableArray *)photos
{
    if (!_photos){
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
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
}

/* Access the photos from Core Data in the viewWillAppear method since this method is called everytime this viewcontroller appears on the screen instead of only the first time (viewDidLoad only is called only when it is created) */
-(void)viewWillAppear:(BOOL)animated
{
    /* Call to the super classes implementation of viewWillAppear */
    [super viewWillAppear:YES];
    
    /* The Photos are stored in Core Data as an NSSet. */
    NSSet *unorderedPhotos = self.album.photos;
    /* To organize them we use a NSSort descriptor to arrange the photos by date. */
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSArray *sortedPhotos = [unorderedPhotos sortedArrayUsingDescriptors:@[dateDescriptor]];
    self.photos = [sortedPhotos mutableCopy];
    
    /* Now that the photos are arranged we reload our CollectionView. */
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /* Confirm that the correct segue is being triggered */
    if ([segue.identifier isEqualToString:@"Detail Segue"])
    {
        /* Confirm that the correct View Controller is being transitioned to */
        if ([segue.destinationViewController isKindOfClass:[TWPhotoDetailViewController class]]){
            
            TWPhotoDetailViewController *targetViewController = segue.destinationViewController;
            NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
            /* Access the photo that was tapped and set the property of the target ViewController */
            Photo *selectedPhoto = self.photos[indexPath.row];
            targetViewController.photo = selectedPhoto;
        }
    }
}

/* When we press the camera button we create a UIImagePickerController and present the avaliable option on the screen. If the camera is avaliable because we are using our phone we show that. If not then we show the Photos Album. */
- (IBAction)cameraBarButtonItemPressed:(UIBarButtonItem *)sender
{
    /* Create a UIImagePicker object and set its' delegate property to self so we can implement the ImagePicker delegate methods */
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    /* If the Camera is avaliable use it to choose the image if not then use the album */
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    [self presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark - Helper Methods

/* Instance method which accepts a UIImage and persists it to Core Data. */
- (Photo *)photoFromImage:(UIImage *)image
{
    /* Create a photo object using the method insertNewObjectForEntityForName for the entity name Photo */
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:[TWCoreDataHelper managedObjectContext]];
    /* Set the photo's attributes */
    photo.image = image;
    photo.date = [NSDate date];
    photo.albumBook = self.album;
    
    NSError *error = nil;
    /* Save the photo, the if statement evaluates to true if there is an error */
    if (![[photo managedObjectContext] save:&error]){
        //Error in saving
        NSLog(@"%@", error);
    }
    return photo;
}

#pragma mark - UICollectionViewDataSource

/* Display the photos stored in the photo's array */
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo Cell";
    
    TWPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    /* Access the correct photo from the photo's array */
    Photo *photo = self.photos[indexPath.row];
    cell.backgroundColor = [UIColor whiteColor];
    cell.imageView.image = photo.image;
    
    return cell;
}

/* Number of items in the collection view should be equal to the number of photos in the photos array */
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.photos count];
}

#pragma mark - UIImagePickerControllerDelegate

/* If the user picks chooses media this delegate method will fire. Using the parameters we can determine which media object they selected. */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if(!image) image = info[UIImagePickerControllerOriginalImage];
    
    [self.photos addObject:[self photoFromImage:image]];
    
    [self.collectionView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* If the user presses cancel dismiss the ImagePickerController */
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
