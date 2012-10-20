osvg
====

XSLT stylesheets to turn openstreetmap xml into svg


How To:

1. Download XML data from openstreetmap.org. Select a region on the map, then click "Export" and choose "OpenStreetMap XML data". The resulting OSM file will be downloaded. 

If the zoom level is such that the map contains a lot of elements, openstreetmap.org will not allow you to save the file, because of its large size. You can use services like http://sharemap.org that will let you download big maps.

2. place the downloaded file in this directory under the name map.osm

3. Make sure you have java available on the command line and make

4. type make

5. The svg file produced is called map.svg


Notes
-----

The difficulty in rendering maps is to select what to render and how.

1. Selecting what to render

This is done in the file called params.xml. The simple syntax allows you to specify what elements to include in the SVG. Some knowledge of the osm format is needed, but it's not that hard.

2. Styling it

This is done in the style.css file. There is a class per type of element, which can be tweaked as per the CSS specification




