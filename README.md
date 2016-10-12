# Feedeater #

## DESCRIPTION ##
Feedeater is an iOS application that allows user to save RSS feeds to have access to the latest news. User can browse news, save them as bookmarks, open full versions in the browser and share via social media or SMS.

## FEATURES ##
* Search for RSS feeds within application add them to your feeds list. Also you can add feeds manually: Just look for the correct RSS URL on the internet and then add new feed in the app using this link.
* Delete unnecessary feeds: delete feed if you feel like you no longer want to follow it.
* See what is new: The app will highlight new stories evety time you checking on the feed. It is also possible to pull to refresh and news list will be updated.
* Search for particular news: You do not need to look for particular story in the list, just type the keyword into search bar to filter stories.
* Create bookmarks: You can save any story in the bookmarks to read it later.
* Open in browser: Press «Open» button next to the story title in the news list or proceed to story details and press «Open with Browser» to open story in internet browser.
* Share on social media: You can either publish a story on your personal page, or send it to a friend.
* Send via SMS: It is possible to even send an SMS with story you like.

## HOW IT WORKS ##
### Add New Feed ###
Press «Add Feed» to open «Add Feed» alert or «+» sign in the top corner of the screen to to go to the feed search where you will be able to search feed by keywords. If you prefer to add feed manually, just fill the fields and press «Add». New feed will be added to internal storage(Core Data). Now you have fully functioning feed you can read news from.
### Edit Feed ###
If you not quite happy with details of your feed, you can edit it, giving it different name or changing its URL address, any changes you will made will be reflected on the data, that is located in the storage.
Delete Feed
To delete feed you need to swipe the list item to left and «Delete» button will appear or you can press edit and then press «Delete». In either way the feed will be permanently deleted from storage. This action cannot be undone.
### Accessing the News ###
If you select one of the feeds you have, you will be taken to the news screen. Every time you opening it, the news are downloaded from the internet using URL provided. It uses Google’s JSON API(https://developers.google.com/feed/v1/jsondevguide) that converts XML page to JSON format, then app puts data from JSON to an array which eventually used to fill the Table View, giving you the nice and easy way to browse the news. Every time user opens news the very first title is saved in User Defaults, so next time the app will compare actual titles with the one that was saved last time, to tell how many new stories were added.
### Searching for News ###
If you will search for something, the news list will update to show only those news that have word or symbol you are searching for. Every time text in search field changes, it checks using localizedCaseInsensitiveContainsString method of NSString if any of news titles contain text user put into search field and changes Table View’s content to things it found using this method.
### Accessing Story Details ###
Select one of the stories in the list and you will be redirected to «Story Details» screen. To display its data, it takes values of the selected story and displays them on the screen. Details screen also allows you to perform several actions, such as:

* Open in browser - opens the story link in the browser, so you can read it.
* Save story to bookmarks - saves title and URL of the story in the internal storage under the relevant feed, so it can be accessed later.
* Share - uses UIActivityViewController to share a story on social media of your choice, it depends on the accounts you saved on your device.
* Send via SMS - picks person from contact list to send him SMS with story link, uses combination of Contacts and UIMessage APIs.
* Facebook «Like» button - uses Facebook framework to give like to a story and share it on your Facebook page.
### Options ###
To access options press «Options» button on the top left part of the screen and Alert Sheet will appear. It contains several options, such as:

* All Bookmarks - opens screen with all bookmarks you have, categorised by the Feed name. Only sections that have bookmarks it them will appear. Pressing on the bookmark will open browser with that story. You can delete bookmarks, by swiping to the left and pressing «Delete» button. Deleting last bookmark in the section will delete the section as well.
* Settings - send you to the settings, where you can set size of the font that will be used for displaying titles of the stories.
* About - sends you on the «About» screen, where you can read info about the application.
