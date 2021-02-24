JSON-scan
=========

Overview
--------

JSON-scan is both a *proposal* for a **standard** for structuring data in arbitrary barcode systems, as well as **sample data and applications**.  This is a _work in progress_ and
this proposal is subject to change.  Feedback is welcome!

As the name implies, the structured data stored in the barcode will use [JSON](http://www.json.org/).

Example
-------

```javascript
{
    "content-type": "image/jpeg",
    "JSONscan": "0.1",
    "name": "Test Image",
    "description": "A test image.",
    "content-url": "http://www.example.com/image/123.jpg"
}
```

Motivation and Philosophy
-------------------------

**Barcodes**, generally speaking, present a machine-readable way to represent data on real-world objects.
In practice, however, barcodes such as [QR Codes](http://en.wikipedia.org/wiki/QR_code) and [Data Matrix codes](http://en.wikipedia.org/wiki/Data_Matrix) attached to posters,
products, or printed materials often yield uninteresting results, often amounting to little more than a redirect to a generic website.

**JSON-scan** is a proposal to create an optional data structure within barcode data which can lead to a more flexible and rich experience when a barcode is scanned.  It does so by allowing any tools
which implement the standard to *route* the user to different behaviors or external "helper" apps (e.g. browser, contacts, phone dialer)
based primarily upon the "**content-type**" and "**content**" of the data.


Details of Data Structure
-------------------------

The format of the data structure is a JSON hash/object.  Within this hash, any valid JSON is allowed, provided it is encodable by (and fits into) the container barcode format.  The exact
content of the hash, other than a few required key/values (see below), is arbitrary and can be tailored as needed by usage or application.

### Required Key/Value Elements ###

Three key/value pairs are proposed as being *required* by the standard: **content-type**, _one_ of: (**src-url** _or_ **content-url** _or_ **content**), and **JSONscan**. 

- `JSONscan` should have a value set which corresponds to the version of the standard the data uses, e.g. "1.0".

- `content-type` should be a valid [MIME type](https://developer.mozilla.org/en-US/docs/Glossary/MIME_type).

- The _actual data_ is defined by **one** of the following.  (If more than one is present, they should be attemped to be used/accessed in this order.)

  - `src-url` - references a remote URL which must contain a valid JSON-scan object.  If this is the case, this fetched structure is used instead.  The "local" and "remote" _content-type_ values must be identical, but the JSONscan version may be different.

  - `content-url` - a remote URL which will access the actual content for the this object.  The content-type of the data at the URL must match the one designated in the JSON-scan object.

  - `content` contains the _actual data_ for the designated type, and thus will vary depending on what that type expects.  In some cases, a JSON sub-object will suffice.  Where some non-JSON format is needed, an encoding method should be chose to encapsulate other data.  Presently the working solution is to include a JSON object of the form `{ "type":"MIME/TYPE", "data":"BASE64-ENCODED-DATA" }`

Parsing Logic Proposal
----------------------

1. Is the encoded barcode data **valid JSON**?  If not, parsing fails.

2. Are there valid values for **JSONscan**, **type**, and **content**/**content-url**/**src-url**?  If not, parsing fails.

3. Some level of sanity check should be made on *JSONscan version number* and the format -- does the application support this version, etc.

4. Sanity check on *type value* -- does the application know what to do with it?  Is there a whitelist/graylist/blacklist mechanism which prevents accessing certain types, urls, manually vs automatically, etc.?  Does it have permission to call out to a helper app?  and so on....

5. If it knows what to do with the type/content combination -- do it!  If it has multiple options, present user with a choice.


### Caveats and Considerations ###

1. Perhaps some types might be "inherit" from other types.  A "photo" might be considered a more specific version of "image", etc.

2. Can both _content_ and _content-url_ be present simultaneously?  If so, which is favorable? If connectivity fails, fall back to local?  Use local as a preview until remote content is retrieved?

3. In the case of _src-url_, will src-url "chaining" be allowed (fetched json contains another src-url)?  Should there be domain restrictions?  etc!

4. Security, security, security.


Example Data
------------

* examples/[image.json](https://raw.githubusercontent.com/naknomum/json-scan/master/examples/image.json) - image (retrieved via URL)
![image](https://raw.githubusercontent.com/naknomum/json-scan/master/images/qr/image.png)

* examples/[event.json](https://raw.githubusercontent.com/naknomum/json-scan/master/examples/event.json) - simple event with embedded iCalendar content (will work offline)
![event](https://raw.githubusercontent.com/naknomum/json-scan/master/images/qr/event.png)

* examples/[event-contenturl.json](https://raw.githubusercontent.com/naknomum/json-scan/master/examples/event-contenturl.json) - same event, JSON-scan content retrieved via URL
![event-contenturl as QR Code](https://raw.githubusercontent.com/naknomum/json-scan/master/images/qr/event-contenturl.png)

![event-contenturl as DataMatrix barcode](https://raw.githubusercontent.com/naknomum/json-scan/master/images/datamatrix/event-contenturl.png)


Example Software
----------------

* **tools/qr/bin_to_qr.pl** - tiny perl utility which takes arbitrary data on stdin and creates QR code on stdout

* **tools/qr/json_to_qr.pl** - perl utility which takes JSON on stdin and creates QR code on stdout

* **tools/qr/json_to_datamatrix.pl** - perl utility which takes JSON on stdin and creates DataMatrix code on stdout

