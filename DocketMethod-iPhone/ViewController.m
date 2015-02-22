//
//  ViewController.m
//  DocketMethod-iPhone
//
//  Created by Kevin Lee on 2/21/15.
//  Copyright (c) 2015 Kevin W. Lee. All rights reserved.
//

#import "ViewController.h"
#import <Firebase/Firebase.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *rootLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)createRootData:(id)sender {
    // Create a reference to a Firebase location
    Firebase *myRootRef = [[Firebase alloc] initWithUrl:@"https://docketmethod.firebaseio.com/"];
    // Write data to Firebase
    [myRootRef setValue:@"Do you have data? You'll love Firebase."];
    
    // Read data and react to changes
    [myRootRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        self.rootLabel.text = snapshot.value;
        NSLog(@"%@ -> %@", snapshot.key, snapshot.value);
    }];

}

- (IBAction)readRootData:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
