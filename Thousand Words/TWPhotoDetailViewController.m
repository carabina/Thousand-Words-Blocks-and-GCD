//
//  TWPhotoDetailViewController.m
//  Thousand Words
//
//  Created by Eliot Arntz on 11/22/13.
//  Copyright (c) 2013 Code Coalition. All rights reserved.
//

#import "TWPhotoDetailViewController.h"
#import "Photo.h"
#import "TWFiltersCollectionViewController.h"

@interface TWPhotoDetailViewController ()

@end

@implementation TWPhotoDetailViewController

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

-(void)viewWillAppear:(BOOL)animated
{
    /* Call to the super classes implementation of viewWillAppear */
    [super viewWillAppear:YES];
    
    /* Set the imageView's image equal to the current photo. */
    self.imageView.image = self.photo.image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /* Confirm that we are using the proper segue and transitioning to the proper ViewController */
    if ([segue.identifier isEqualToString:@"Filter Segue"]){
        if ([segue.destinationViewController isKindOfClass:[TWFiltersCollectionViewController class]]){
            
            /* Set the targetViewController's photo property. The FiltersCollectionViewController will now have access to the photo object. */
            TWFiltersCollectionViewController *targetViewController = segue.destinationViewController;
            targetViewController.photo = self.photo;
        }
    }
}

- (IBAction)addFilterButtonPressed:(UIButton *)sender {
}

- (IBAction)deleteButtonPressed:(UIButton *)sender
{
    /* Access the managed object context from our photo. Then tell core data to delete the photo object. */
    [[self.photo managedObjectContext] deleteObject:self.photo];
    
    NSError *error = nil;
    
    /* Calling save is unecessary except that we are doing our testing on the simulator and auto saving does not work properly on it.*/
    [[self.photo managedObjectContext] save:&error];
    
    if (error){
        NSLog(@"error");
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
