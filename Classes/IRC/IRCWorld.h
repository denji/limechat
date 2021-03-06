// Copyright (C) 2007-2014 Satoshi Nakagawa <psychs AT limechat DOT net>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "ChatBox.h"
#import "DCCController.h"
#import "FieldEditorTextView.h"
#import "IRCChannelConfig.h"
#import "IRCClientConfig.h"
#import "IRCTreeItem.h"
#import "IRCWorldConfig.h"
#import "IconController.h"
#import "InputTextField.h"
#import "LimeChatApplication.h"
#import "LogController.h"
#import "MainWindow.h"
#import "MemberListView.h"
#import "MenuController.h"
#import "NotificationController.h"
#import "ServerTreeView.h"
#import "ViewTheme.h"
#import <Cocoa/Cocoa.h>

@class AppController;

@interface IRCWorld : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate, NotificationControllerDelegate>

@property ( nonatomic, weak ) AppController *app;
@property ( nonatomic, weak ) MainWindow *window;
@property ( nonatomic, weak ) id<NotificationController> notifier;
@property ( nonatomic, weak ) ServerTreeView *tree;
@property ( nonatomic, weak ) InputTextField *text;
@property ( nonatomic, weak ) NSBox *logBase;
@property ( nonatomic, weak ) NSBox *consoleBase;
@property ( nonatomic, weak ) ChatBox *chatBox;
@property ( nonatomic ) FieldEditorTextView *fieldEditor;
@property ( nonatomic, weak ) MemberListView *memberList;
@property ( nonatomic, weak ) MenuController *menuController;
@property ( nonatomic, weak ) DCCController *dcc;
@property ( nonatomic, weak ) ViewTheme *viewTheme;
@property ( nonatomic ) NSMenu *treeMenu;
@property ( nonatomic ) NSMenu *logMenu;
@property ( nonatomic ) NSMenu *consoleMenu;
@property ( nonatomic ) NSMenu *urlMenu;
@property ( nonatomic ) NSMenu *addrMenu;
@property ( nonatomic ) NSMenu *chanMenu;
@property ( nonatomic ) NSMenu *memberMenu;
@property ( nonatomic ) LogController *consoleLog;

@property ( nonatomic, readonly ) NSMutableArray *clients;
@property ( nonatomic ) IRCTreeItem *selected;
@property ( nonatomic, readonly ) IRCClient *selectedClient;
@property ( nonatomic, readonly ) IRCChannel *selectedChannel;

- (void)setup:(IRCWorldConfig *)seed;
- (void)setupTree;
- (void)save;
- (NSMutableDictionary *)dictionaryValue;

- (void)setServerMenuItem:(NSMenuItem *)item;
- (void)setChannelMenuItem:(NSMenuItem *)item;

- (void)onTimer;
- (void)autoConnect:(BOOL)afterWakeUp;
- (void)terminate;
- (void)prepareForSleep;

- (IRCClient *)findClient:(NSString *)name;
- (IRCClient *)findClientById:(int)uid;
- (IRCChannel *)findChannelByClientId:(int)uid channelId:(int)cid;

- (void)select:(id)item;
- (void)selectChannelAt:(int)n;
- (void)selectClientAt:(int)n;
- (void)selectPreviousItem;

- (void)focusInputText;
- (BOOL)inputText:(NSString *)s command:(NSString *)command;

- (void)markAllAsRead;
- (void)markAllScrollbacks;

- (void)updateIcon;
- (void)reloadTree;
- (void)adjustSelection;
- (void)expandClient:(IRCClient *)client;

- (void)updateTitle;
- (void)updateClientTitle:(IRCClient *)client;
- (void)updateChannelTitle:(IRCChannel *)channel;

- (void)sendUserNotification:(UserNotificationType)type title:(NSString *)title desc:(NSString *)desc context:(id)context;

- (void)preferencesChanged;
- (void)reloadTheme;
- (void)changeTextSize:(BOOL)bigger;

- (IRCClient *)createClient:(IRCClientConfig *)seed reload:(BOOL)reload;
- (IRCChannel *)createChannel:(IRCChannelConfig *)seed client:(IRCClient *)client reload:(BOOL)reload adjust:(BOOL)adjust;
- (IRCChannel *)createTalk:(NSString *)nick client:(IRCClient *)client;

- (void)destroyChannel:(IRCChannel *)channel;
- (void)destroyClient:(IRCClient *)client;

- (void)logKeyDown:(NSEvent *)e;
- (void)logDoubleClick:(NSString *)s;

@end
