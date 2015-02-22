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
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.items = [NSMutableDictionary dictionary];
    self.rootRef = [[Firebase alloc] initWithUrl:@"https://docketmethod.firebaseio.com/"];

    [self.rootRef observeSingleEventOfType:FEventTypeValue andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *prevKey) {
        [self.items addEntriesFromDictionary:snapshot.value];
        NSLog(@"%@ -> %@", snapshot.key, snapshot.value);
        [self.tableView reloadData];

        //begin monitoring changes
        [self monitorFireBase];
    }];
    

}

- (NSIndexPath *)indexPathForKey:(NSString *)key {
    NSUInteger i = [self.items.allKeys indexOfObject:key];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
    return indexPath;
}

- (void)monitorFireBase {
    
    [self.rootRef observeEventType:FEventTypeChildAdded andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *previousKey) {
        NSLog(@"Added %@ -> %@", snapshot.key, snapshot.value);

        NSIndexPath *indexPath = [self indexPathForKey:snapshot.key];
        
        [self.tableView beginUpdates];
        [self.items setValue:snapshot.value forKey:snapshot.key];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }];
    
    [self.rootRef observeEventType:FEventTypeChildChanged andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *previousKey) {
        NSLog(@"Changed %@ -> %@", snapshot.key, snapshot.value);

        NSIndexPath *indexPath = [self indexPathForKey:snapshot.key];
        
        [self.items setValue:snapshot.value forKey:snapshot.key];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }];

    [self.rootRef observeEventType:FEventTypeChildRemoved andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *previousKey) {
        NSLog(@"Deleted %@ -> %@", snapshot.key, snapshot.value);
        
        NSIndexPath *indexPath = [self indexPathForKey:snapshot.key];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.items removeObjectForKey:snapshot.key];
        [self.tableView endUpdates];        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [[self.items allKeys] objectAtIndex:indexPath.row];
    NSString *value = self.items[key];
    NSString *newVaule = [NSString stringWithFormat:@"Updated %@", value];
    [self.rootRef updateChildValues:@{key:newVaule}];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (void)dealloc {
    [self.rootRef removeAllObservers];
}
@end
