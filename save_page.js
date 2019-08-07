var system = require('system');
var page = require('webpage').create();

page.settings.loadImages = false;
page.open(system.args[1], function()
{
    console.log(page.content);
    phantom.exit();
});
