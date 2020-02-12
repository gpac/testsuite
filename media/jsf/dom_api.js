import {XMLHttpRequest} from 'xhr'

filter.pids = [];

//metadata
filter.set_name("DOMAPI");
filter.set_desc("JS DOM API tests");
filter.set_version("0.1beta");
filter.set_author("GPAC team");
filter.set_help("This filter provides a very simple javascript test for DOM APIs");

//just do an XHR and exit, no process/configure pid 
filter.initialize = function() {
 do_xhr();
}

function do_xhr()
{
 filter.xhr = new XMLHttpRequest();
 filter.xhr.responseType = "document";
 filter.xhr.onload = function()
 {
 	if (! this.response) return;

 	let doc = this.response;
 	if (!doc) return;
 	dom_api_tests(doc);
 };
 filter.xhr.onerror = function() {
};
filter.xhr.onreadystatechange = function() {
  if (this.readyState != 4) return;
};

 filter.xhr.open("GET", "media/svg/shapes-circle-01-t.svg");
 filter.xhr.send();	
}

function dom_api_tests(doc)
{
	//element to string
	print('doc is ' + doc.documentElement);
	print('doc namespace is ' + doc.documentElement.namespaceURI);
	let elt = doc.getElementById("revision");
	print('elt is ' + elt);
	print('elt tag is ' + elt.tagName);
	print('elt local name is ' + elt.localName);
	
	print('elt has attr ' + elt.hasAttribute('x') );
	print('elt.x is ' + elt.getAttribute('x') );
	elt.setAttribute('x', 20);
	elt.setIdAttribute('toto', false);
	elt.removeAttribute('x');

	elt = doc.getElementById("test-body-content");
	print('prev elt is ' + elt.previousSibling);
	print('elt has child: ' + elt.hasChildNodes() );
	print('elt has child: ' + elt.hasAttributes() );
	elt.cloneNode();
	let nl = elt.childNodes;
	print('nb children of elt: ' + nl.length);
	print('3rd child of elt: ' + nl.item(3) );

	let txt = doc.createTextNode();
	let txt2 = doc.createTextNode("super text");
	print('text length is: ' + txt2.length);
	txt.data = "new text";

	txt.isSameNode(txt2);
	elt.insertBefore(txt);
	elt.replaceChild(txt2, txt);
	elt.removeChild(txt2);

	try {
		elt.lookupPrefix();
	} catch { }

	try {
		doc.xmlVersion = 2;
	} catch { }

	let circles = doc.getElementsByTagName('circle');


	elt.setAttribute('onclick', "print('click');");

	doc.addEventListener('click', "print('click');");
	doc.removeEventListener('click');

}