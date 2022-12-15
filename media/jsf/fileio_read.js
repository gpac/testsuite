import * as evg from 'evg'
import { Sys as sys } from 'gpaccore'
import { FileIO as FileIO } from 'gpaccore'
import { File as File } from 'gpaccore'

let src = new FileIO(
"../../results/temp/jsf-fileio/live.mpd",
//open
function(url, mode) {
	this.target = new File(url, mode);
	return true;
},
//close
function() {
	this.target.close();
},
//write
function(buf)
{
	return this.target.write(buf);
},
//read
function(buf)
{
	return this.target.read(buf);
},
//seek
function(offset, whence)
{
	return this.target.seek(offset, whence);
},
//tell
function()
{
	return this.target.pos;
},
//eof
function()
{
	return this.target.eof;
},
//exists
function(url)
{
	return sys.file_exists(url);
}
);

src.protect();

session.add_filter('src='+src.url);
session.add_filter('inspect:deep:log=./results/temp/jsf-fileio/inspect.txt');
//session.add_filter('vout');

//post a task to print status every second
session.post_task( ()=> 
{
 if (session.last_task) {
	src.destroy();
 	return false;
 }
 return 1000;
});


