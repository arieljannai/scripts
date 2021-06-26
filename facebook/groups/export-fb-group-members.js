const timer = ms => new Promise(res => setTimeout(res, ms));
const usersData = {}
let usersDataArray = [];
let usersDataString = '';
let usersDataStringReversed = '';

let copyTextarea = document.createElement('textarea');
copyTextarea.style['display'] = 'none';
document.body.appendChild(copyTextarea);

let elmNewToTheGroup = document.evaluate("//span[contains(., 'New to the Group')]", document).iterateNext();
elmNewToTheGroup.scrollIntoView();

let elmNewMembers = elmNewToTheGroup.closest('div.rq0escxv.l9j0dhe7.du4w35lb.j83agx80.cbu4d94t.pfnyh3mw.d2edcug0.aahdfvyu.tvmbv18p').parentNode.children[1].firstChild;

async function getData(nameToStopAt) {
	let child = elmNewMembers.firstChild;

	while (child) {
		let childData = child.querySelector('span > span > span.nc684nl6 > *');
		let link = childData.href;
		let name = childData.textContent;
		let t = link ? link.match(/\/(\d+)\/$/) : null;
		let id = t ? t[1] : name;
		usersData[id] = {'name': name, 'link': link};
		usersDataArray.push(name + '\t' + link);
		usersDataString += name + '\t' + link + '\n';
		usersDataStringReversed = name + '\t' + link + '\n' + usersDataStringReversed;
		
		child.remove();
		child = elmNewMembers.firstChild;
		
		if (name === nameToStopAt) {
			break;
		}

		await timer(200);
	}
	
	usersDataStringReversed + '\n\t\n\t\n\t';

	console.info(usersDataStringReversed);
	console.info('\n');

	try {
		await navigator.clipboard.writeText(usersDataStringReversed);
		console.log('List copied to clipboad, use Ctrl+V to paste at your destination');
	} catch (err) {
		console.error('Failed to copy: ', err);
	}

	
}

getData('');

