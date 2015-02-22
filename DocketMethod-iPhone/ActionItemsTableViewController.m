//
//  ActionItemsTableViewController.m
//  DocketMethod-iPhone
//
//  Created by Kevin Lee on 2/21/15.
//  Copyright (c) 2015 Kevin W. Lee. All rights reserved.
//

#import "ActionItemsTableViewController.h"
#import <Firebase/Firebase.h>

@interface ActionItemsTableViewController ()
@property (nonatomic, strong) NSMutableDictionary *items;
@property (nonatomic, strong) Firebase *rootRef;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ActionItemsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.items = [NSMutableDictionary dictionary];
    self.rootRef = [[Firebase alloc] initWithUrl:@"https://docketmethod.firebaseio.com/"];
//    [[self.rootRef childByAutoId] setValue:@"Kevin"];
//    [[self.rootRef childByAutoId] setValue:@"Natalie"];
//    [[self.rootRef childByAutoId] setValue:@"Warren"];
    // Read data and react to changes
    [self.rootRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self.items addEntriesFromDictionary:snapshot.value];
        NSLog(@"%@ -> %@", snapshot.key, snapshot.value);
        [self.tableView reloadData];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FirebaseCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *key = [[self.items allKeys] objectAtIndex:indexPath.row];
    NSString *value = self.items[key];
    cell.textLabel.text = value;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
