	const timer = ms => new Promise(res => setTimeout(res, ms));
	let actionsData = {};
	let actions = $('div[role=main] > div > div.dati1w0a *> div.b20td4e0.muag1w35 > div');
	let actionsCounter = 0;
	let actionsLog = '';

	async function exportActivityLog() {
		while (actions.length) {
			let lastActionDate = '';
			for (let i = 0; i < actions.length; i++) {
				let data = actions[i].querySelectorAll('span.knj5qynh');
				actionsLog += 
					(data[1].innerHTML + '    |    ' + data[0].innerHTML + '<br><br>\n\n')
					.replaceAll(/ class=".*?"/g, '').replaceAll('div','span').replaceAll('href="/', 'href="https://fb.com/');
				
				
				let a = data[0].textContent.match(/removed|approved|blocked|declined|muted|accepted|invited/);
				let actionType = a ? a[0] : 'unknown action';
				let actionDate = data[1].textContent;
				
				if (actionType === 'accepted' || actionType === 'invited') break;
				
				let adminName = data[0].children[0].textContent;
				let adminLink = data[0].children[0].href;
				let memberName = data[0].children[1].textContent;
				let memberLink = data[0].children[1].href;
				let t = memberLink ? memberLink.match(/\/(\d+)\/$/) : null;
				let id = t ? t[1] : memberName;
				
				switch(actionType) {
					case 'removed':
						actionsData[id] = {
							'memberName': memberName,
							'memberLink': memberLink,
							'actionType': actionType,
							'actionDate': actionDate,
							'blocked' : false,
							'adminName': adminName,
							'adminLink': adminLink
						}
						actionsCounter++;
						break;
					case 'approved':
						if (!actionsData[id]) {
							actionsData[id] = {
								'memberName': memberName,
								'memberLink': memberLink,
								'actionType': actionType,
								'actionDate': actionDate,
								'blocked' : false,
								'adminName': adminName,
								'adminLink': adminLink
							}
							actionsCounter++;
						}
						break;
					case 'blocked':
						if (actionsData[id]) {
							actionsData[id]['blocked'] = true;
						} else {
							actionsData[id] = {
								'memberName': memberName,
								'memberLink': memberLink,
								'actionType': actionType,
								'actionDate': actionDate,
								'blocked' : true,
								'adminName': adminName,
								'adminLink': adminLink,
							}
							actionsCounter++;
						}
						break;
					default:
				}
				
				lastActionDate = actionDate;
				await timer(50);
			}
			
			console.log(`${lastActionDate} is the oldest date checked`);
			console.log(`${actionsCounter} users saved in log so far`);
			
			actions.remove();
			await timer(300);
			// remove empty sections
			$('div[role=main] > div > div.dati1w0a').filter(function(i,x) { return !x.querySelector('div.b20td4e0.muag1w35 > div'); }).remove();
			await timer(500);
			actions = $('div[role=main] > div > div.dati1w0a *> div.b20td4e0.muag1w35 > div');
			

			for (let i = 1; i <= 5 && !actions.length; i++) {
				await timer(2000 * i);
				actions = $('div[role=main] > div > div.dati1w0a *> div.b20td4e0.muag1w35 > div');
			}
		}
	}

	exportActivityLog();
