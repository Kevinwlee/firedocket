//
//  ActionItemsTableViewController.m
//  DocketMethod-iPhone
//
//  Created by Kevin Lee on 2/21/15.
//  Copyright (c) 2015 Kevin W. Lee. All rights reserved.
//

#import "ActionItemsTableViewController.h"
#import <Firebase/Firebase.h>
#import <FontAwesomeKit/FAKFontAwesome.h>
#import <FontAwesomeKit/FAKFoundationIcons.h>
#import <FontAwesomeKit/FAKZocial.h>
#import <FontAwesomeKit/FAKIonIcons.h>


@interface ActionItemsTableViewController ()
@property (nonatomic, strong) NSMutableDictionary *items;
@property (nonatomic, strong) NSMutableDictionary *importantItems;
@property (nonatomic, strong) Firebase *rootRef;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ActionItemsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.items = [NSMutableDictionary dictionary];
    self.importantItems = [NSMutableDictionary dictionary];
    self.rootRef = [[Firebase alloc] initWithUrl:@"https://intense-fire-3296.firebaseio.com/2/action_items"];
    
    Firebase *mitRef = [[Firebase alloc] initWithUrl:@"https://intense-fire-3296.firebaseio.com/2/mit"];
    Firebase *docketRef = [[Firebase alloc] initWithUrl:@"https://intense-fire-3296.firebaseio.com/2/dockets"];
    
    [mitRef observeSingleEventOfType:FEventTypeValue andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *prevKey) {
        [self.importantItems addEntriesFromDictionary:snapshot.value];
        NSLog(@"%@ -> %@", snapshot.key, snapshot.value);
        [self.tableView reloadData];
        
    }];
    
    
    [self.rootRef observeSingleEventOfType:FEventTypeValue andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *prevKey) {
        [self.items addEntriesFromDictionary:snapshot.value];
        NSLog(@"%@ -> %@", snapshot.key, snapshot.value);
        [self.tableView reloadData];

        //begin monitoring changes
        [self monitorFireBase];
    }];
    

}

- (NSIndexPath *)indexPathForKey:(NSString *)key section:(NSInteger)section {
    NSUInteger i = [self.items.allKeys indexOfObject:key];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
    return indexPath;
}

- (void)monitorFireBase {
    
    [self.rootRef observeEventType:FEventTypeChildAdded andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *previousKey) {
        NSLog(@"Added %@ -> %@", snapshot.key, snapshot.value);

        NSIndexPath *indexPath = [self indexPathForKey:snapshot.key section:1];
        
        [self.tableView beginUpdates];
        [self.items setValue:snapshot.value forKey:snapshot.key];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }];
    
    [self.rootRef observeEventType:FEventTypeChildChanged andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *previousKey) {
        NSLog(@"Changed %@ -> %@", snapshot.key, snapshot.value);

        NSIndexPath *indexPath = [self indexPathForKey:snapshot.key section:1];
        
        [self.items setValue:snapshot.value forKey:snapshot.key];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }];

    [self.rootRef observeEventType:FEventTypeChildRemoved andPreviousSiblingKeyWithBlock:^(FDataSnapshot *snapshot, NSString *previousKey) {
        NSLog(@"Deleted %@ -> %@", snapshot.key, snapshot.value);
        
        NSIndexPath *indexPath = [self indexPathForKey:snapshot.key section:1];
        
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
    return 3;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    FAKFontAwesome *starIcon = [FAKFontAwesome starIconWithSize:15];
//    [starIcon characterCode];
//    NSAttributedString *mit = [[NSAttributedString alloc] initWithString: @" MIT"];
//    NSMutableAttributedString *star = [[NSMutableAttributedString alloc] initWithAttributedString:[starIcon attributedString]];
//    [star appendAttributedString:mit];
//    UILabel *atributedLabel = [[UILabel alloc] init];
//    atributedLabel.attributedText = star;
//
//    FAKFontAwesome *squareOIcon = [FAKFontAwesome squareOIconWithSize:15];
//    [starIcon characterCode];
//    NSAttributedString *action = [[NSAttributedString alloc] initWithString: @" Action Items"];
//    NSMutableAttributedString *square = [[NSMutableAttributedString alloc] initWithAttributedString:[squareOIcon attributedString]];
//    [square appendAttributedString:action];
//    
//    switch (section) {
//        case 0:
//            atributedLabel.attributedText = star;
//            return atributedLabel;
//            break;
//            
//        default:
//            atributedLabel.attributedText = square;
//            return atributedLabel;
//            break;
//    }
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return @"MIT";
            break;
        case 1:
            return @"Action Items";
            break;
        case 2:
            return @"Docket";
            break;
        default:
            return @"Action Items";
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return [self.importantItems count];
            break;
        case 1:
            return [self.items count];
            break;
        default:
            return 0;
            break;
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FirebaseCell" forIndexPath:indexPath];
    
    NSString *key;
    NSDictionary *item;
    switch (indexPath.section) {
        case 0:
            key = [[self.importantItems allKeys] objectAtIndex:indexPath.row];
            item = self.importantItems[key];
            break;
            
        default:
            key = [[self.items allKeys] objectAtIndex:indexPath.row];
            item = self.items[key];

            break;
    }

    cell.textLabel.text = item[@"text"];

    if ([item[@"completed"] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)toggleActionItemCompletion:(NSIndexPath *)indexPath {
    NSString *key = [[self.items allKeys] objectAtIndex:indexPath.row];
    NSMutableDictionary *item = self.items[key];

    
    if ([item[@"completed"] boolValue]) {
        [item setValue:@"false" forKey:@"completed"];
    } else {
        [item setValue:@"true" forKey:@"completed"];
    }
    
    [self.rootRef updateChildValues:@{key:item} withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error) {
            NSLog(@"Error %@", error);
        }
        
    }];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *key;
    NSMutableDictionary *item;
    
    switch (indexPath.section) {
        case 0:
            key = [[self.importantItems allKeys] objectAtIndex:indexPath.row];
            item = self.importantItems[key];

            NSLog(@"Item %@", item);

            break;
        case 1:
            
            [self toggleActionItemCompletion:indexPath];

            break;
        default:
            break;
    }

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
