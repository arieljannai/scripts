// Instructions
// 1. Go the the requests page of your group
// 2. Filter as you wish to
// 3. Scroll to the bottom to load all the requests
// 4. Open DevTools (F12)
// 5. Change the second parameter at the end from false to true if you wish to automatically open all the chats
// 6. Run the script
// 7. The output is now copied to your clipboard

// Send messages quickly
// 1. Copy the message you want to send everyone
// 2. Go to the leftmost chat
// 3. Ctrl + V
// 4. Tab
// 5. Repeat steps 3-4 until you reach the rightmost chat
// 6. Close those chats
// 7. Repeat from 2 until done



function openAllChats(userRequests) {
	for (var i = 0; i < userRequests.length; i++) {
		$(userRequests[i]).find('.uiPopover > a *> i').click();
		$('.uiContextualLayerPositioner.uiLayer:not(".hidden_elem") > .uiContextualLayer.uiContextualLayerBelowRight *> span:contains("Message"):last').click();
	}
}


function exportVisibleRequests(copyToClipboard, openChats) {

	let myName = $('a[title="Profile"] *> span').text();
	let currentDate = new Date(Date.now()).toLocaleDateString('he-il');

	let userRequests = $('#member_requests_pagelet *> ul.uiList:first > li > div > div:last-child');
	let finalString = '';

	for (var i = 0; i < userRequests.length; i++) {
		let currentRequest = $(userRequests[i]);
		
		let profileCard = currentRequest.find('a[data-hovercard^="/ajax/hovercard"]')[0];
		let profileLink = profileCard['href'];
		let profileName = profileCard.text;
		
		let mutualFriendsCount = currentRequest.find('div > ul *> a:contains("Mutual Friend")').text().replace(/ Mutual Friends?/, '');
		let hasMutualFriends = mutualFriendsCount > 0 ? 'כן' : 'לא';

		finalString += profileName + '\t' + profileLink + '\t' + myName + '\t' + hasMutualFriends + '\t' + currentDate  + '\t\t\n';
	}

	console.log(finalString);
	console.log();
	
	if (copyToClipboard) {
		copy(finalString);
		console.log('The output was copied to the clipboard!\nGo ahead and paste in the excel.');
	}

	if (openChats) {
		openAllChats(userRequests);
	}
}

exportVisibleRequests(true, false);