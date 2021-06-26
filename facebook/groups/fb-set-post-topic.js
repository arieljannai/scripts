const timer = ms => new Promise(res => setTimeout(res, ms));
const msWait = 400;

async function setTopic(topic) {
	$('div[aria-label="Actions for this post"]')[0].click();
	await timer(msWait);
	$('div > div > div[role="menuitem"]').filter(function(i,x) { return x.querySelector('div > div > div > span').innerHTML.contains('post topic') }).click();
	await timer(msWait);
	$('input[type="search"]').last()[0].click();
	await timer(msWait);
	$('div[role="listbox"] *> ul > li').map(function(i,x) { return x.querySelector('div *> span') }).filter(function(i,x){return x.innerHTML.contains(topic)}).click();
	await timer(msWait);
	$('div[aria-label="Save"]')[0].click();
}

setTopic('הצגה עצמית');

function isVisible(x) {
	return x.offsetWidth > 0 && x.offsetHeight > 0;
}
