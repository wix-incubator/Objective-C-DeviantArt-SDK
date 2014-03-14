//
//  DVNTMasterViewController.m
//  deviantART SDK
//
//  Created by Aaron Pearce on 13/11/13.
//  Copyright (c) 2013 deviantART. All rights reserved.
//

#import "DVNTMasterViewController.h"
#import "DVNTAPI.h"

@interface DVNTMasterViewController () {
    
}

@property (nonatomic) NSMutableArray *items;
@property (nonatomic) BOOL authenticating;
@property (nonatomic) UIActivityIndicatorView *activitySpinner;
@property (nonatomic) UIBarButtonItem *runTestsButton;
@property (nonatomic) UIBarButtonItem *spinnerButton;
@end

@implementation DVNTMasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Bootstrap";
    
    self.items = [NSMutableArray array];
    
    self.activitySpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activitySpinner.color = [UIColor blackColor];
    
    self.spinnerButton = [[UIBarButtonItem alloc] initWithCustomView:self.activitySpinner];
    self.runTestsButton = [[UIBarButtonItem alloc] initWithTitle:@"Run Tests" style:UIBarButtonItemStylePlain target:self action:@selector(testAPI)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log In" style:UIBarButtonItemStylePlain target:self action:@selector(loginOrLogout)];
    
    self.navigationItem.rightBarButtonItem = self.runTestsButton;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self authenticate];
}

- (void)testAPI {
    /// DO NOT ASK HOW THIS WORKS... ITS A HACK FOR TESTING ///
    
    // clear the table and array before starting
    [self clearItems];
    
    // show a activity indicator in the right button
    [self.activitySpinner startAnimating];
    self.navigationItem.rightBarButtonItem = self.spinnerButton;
    
    // dim the left button
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    // Let's grab your user info!
    NSMutableDictionary *whoami = [NSMutableDictionary dictionaryWithObject:@"user/whoami" forKey:@"call"];
    [DVNTAPIRequest whoAmIWithSuccess:^(NSURLSessionDataTask *task, id JSON) {
        [whoami setObject:@"success" forKey:@"status"];
        [self insertItem:whoami];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [whoami setObject:@"failed" forKey:@"status"];
        [self insertItem:whoami];
    }];
    
    // damntoken test
    NSMutableDictionary *damntoken = [NSMutableDictionary dictionaryWithObject:@"user/damntoken" forKey:@"call"];
    [DVNTAPIRequest damnTokenWithSuccess:^(NSURLSessionDataTask *task, id JSON) {
        [damntoken setObject:@"success" forKey:@"status"];
        [self insertItem:damntoken];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [damntoken setObject:@"failed" forKey:@"status"];
        [self insertItem:damntoken];
    }];
    
    // available/total space test
    NSMutableDictionary *space = [NSMutableDictionary dictionaryWithObject:@"stash/space" forKey:@"call"];
    [DVNTAPIRequest spaceWithSuccess:^(NSURLSessionDataTask *task, id JSON) {
        [space setObject:@"success" forKey:@"status"];
        [self insertItem:space];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [space setObject:@"failed" forKey:@"status"];
        [self insertItem:space];
    }];
    
    // used for later calls
    __block NSString *stashid;
    __block NSString *folderid;

    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"png"];
    
    // upload test
    NSMutableDictionary *submit = [NSMutableDictionary dictionaryWithObject:@"stash/submit" forKey:@"call"];
    [DVNTAPIRequest uploadImageFromFilePath:path parameters:nil success:^(NSURLSessionDataTask *task, id JSON) {
        [submit setObject:JSON[@"status"] forKey:@"status"];
        [self insertItem:submit];
        
        // set these for later
        stashid = JSON[@"stashid"];
        folderid = JSON[@"folderid"];
        
        // folder metadata test
        NSMutableDictionary *folderMetadata = [NSMutableDictionary dictionaryWithObject:@"stash/metadata (folder)" forKey:@"call"];
        [DVNTAPIRequest folderMetadata:folderid success:^(NSURLSessionDataTask *task, id JSON) {
            [folderMetadata setObject:@"success" forKey:@"status"];
            [self insertItem:folderMetadata];
            
            // rename folder
            NSMutableDictionary *renameFolder = [NSMutableDictionary dictionaryWithObject:@"stash/folder" forKey:@"call"];
            [DVNTAPIRequest renameFolder:folderid folderName:@"New Folder" success:^(NSURLSessionDataTask *task, id JSON) {
                [renameFolder setObject:JSON[@"status"] forKey:@"status"];
                [self insertItem:renameFolder];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [renameFolder setObject:@"failed" forKey:@"status"];
                [self insertItem:renameFolder];
            }];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [folderMetadata setObject:@"failed" forKey:@"status"];
            [self insertItem:folderMetadata];
        }];
        
        // item metadata test
        NSMutableDictionary *itemMetadata = [NSMutableDictionary dictionaryWithObject:@"stash/metadata (item)" forKey:@"call"];
        [DVNTAPIRequest itemMetadata:stashid success:^(NSURLSessionDataTask *task, id JSON) {
            [itemMetadata setObject:@"success" forKey:@"status"];
            [self insertItem:itemMetadata];
            
            // get item media
            NSMutableDictionary *itemMedia = [NSMutableDictionary dictionaryWithObject:@"stash/media" forKey:@"call"];
            [DVNTAPIRequest itemMedia:stashid success:^(NSURLSessionDataTask *task, id JSON) {
                [itemMedia setObject:@"success" forKey:@"status"];
                [self insertItem:itemMedia];
                
                // delete item
                NSMutableDictionary *deleteItem = [NSMutableDictionary dictionaryWithObject:@"stash/delete" forKey:@"call"];
                [DVNTAPIRequest deleteItem:stashid success:^(NSURLSessionDataTask *task, id JSON) {
                    [deleteItem setObject:JSON[@"status"] forKey:@"status"];
                    [self insertItem:deleteItem];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [deleteItem setObject:@"failed" forKey:@"status"];
                    [self insertItem:deleteItem];
                }];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [itemMedia setObject:@"failed" forKey:@"status"];
                [self insertItem:itemMedia];
            }];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [itemMetadata setObject:@"failed" forKey:@"status"];
            [self insertItem:itemMetadata];
        }];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [submit setObject:@"failed" forKey:@"status"];
        [self insertItem:submit];
    }];
    
    NSMutableDictionary *oembed = [NSMutableDictionary dictionaryWithObject:@"backend/oembed" forKey:@"call"];
    [DVNTAPIRequest OEmbedWithQuery:@"url=http%3A%2F%2Ffav.me%2Fd2enxz7" success:^(NSURLSessionDataTask *task, id JSON) {
        NSString *status = @"failed";
        if([JSON[@"author_name"] isEqualToString:@"pachunka"]) status = @"success";
        
        [oembed setObject:status forKey:@"status"];
        [self insertItem:oembed];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [oembed setObject:@"failed" forKey:@"status"];
        [self insertItem:oembed];
    }];
    
    NSMutableDictionary *delta = [NSMutableDictionary dictionaryWithObject:@"stash/delta" forKey:@"call"];
    [DVNTAPIRequest deltaWithCursor:nil success:^(NSURLSessionDataTask *task, id JSON) {

        [delta setObject:(JSON[@"cursor"]) ? @"success" : @"failed" forKey:@"status"];
        [self insertItem:delta];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [delta setObject:@"failed" forKey:@"status"];
        [self insertItem:delta];
    }];
}

- (void)insertItem:(NSDictionary *)item {
    [self.items insertObject:item atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // manual hack for this-
    if(self.items.count == 10) {
        self.navigationItem.rightBarButtonItem = self.runTestsButton;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

- (void)clearItems {
    [self.items removeAllObjects];
    [self.tableView reloadData];
}

- (void)loginOrLogout {
    if ([DVNTAPIClient isAuthenticated]) {
        [DVNTAPIClient unauthenticate];
        [self clearItems];
        [self.navigationItem.leftBarButtonItem setTitle: @"Log In"];
    } else {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        [self authenticate];
    }
}

- (void)authenticate {
    // T12243 we're already trying to authenticate the user, no need to prompt again until completionHandler has run
    if (self.authenticating) {
        return;
    }
    
    self.authenticating = YES;
    
    // Check if App has authenticated user at least once and has credentials, if not show the UI, will also refresh token if needed here
    [DVNTAPIClient authenticateFromController:self scope:@"basic" completionHandler:^(NSError *error) {
        self.authenticating = NO;
        
        self.navigationItem.leftBarButtonItem.enabled = YES;
        
        if(!error && [DVNTAPIClient isAuthenticated]) {
            [self.navigationItem.leftBarButtonItem setTitle: @"Log Out"];
            [self testAPI];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *item = self.items[indexPath.row];

    cell.textLabel.text = item[@"call"];
    
    NSString *status = item[@"status"];
    cell.detailTextLabel.text = [status capitalizedString];
    
    if([status isEqualToString:@"success"]) {
        cell.detailTextLabel.textColor = [UIColor greenColor];
    } else {
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
     
    return cell;
}

@end
