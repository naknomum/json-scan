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
    "type": "image",
    "JSONSCAN": "0.1",
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
which implement the standard to *route* the user to different behaviors or external apps based primarily upon the "**type**" and "**content**" of the data.


Details of Data Structure
-------------------------

The format of the data structure is a JSON hash/object.  Within this hash, any valid JSON is allowed, provided it is encodable by (and fits in) the enveloping barcode format.  The exact
content of the hash, other than a few required key/values (see below), is arbitrary and can be tailored as needed by usage or application.

### Required Key/Value Elements ###

Three key/value pairs are proposed as being *required* by the standard: **type**, [ **content** _or_ **content-url** ], and **JSONSCAN**. 

- **JSONSCAN** should have a value set which corresponds to the version of the standard the data uses, e.g. "1.0".

- **type** should be a well-defined set of keywords, based, loosely-speaking, upon general functionality of content, e.g. _event_, _menu_, _code_, _social_. Ultimately, a more formal body should arbitrate this list and/or combine efforts with other similar standardizations.

- **content** contains the data for the designated type, and thus will vary depending on what that type expects.  In some cases, a JSON sub-object will suffice.  Where some non-JSON format is needed, an encoding method should be chose to encapsulate other data.  Presently the working solution is to include a JSON object of the form `{ "type":"MIME/TYPE", "data":"BASE64-ENCODED-DATA" }`

- **content-url** is an alternate for **content**.  In this case, the value should be a URL which will access the content for the this object.  This will likely be a useful feature, given the small
storage capacity of most barcode formats.


Parsing Logic Proposal
----------------------

1. Is the encoded barcode data **valid JSON**?  If not, parsing fails.

2. Are there valid values for **JSONSCAN**, **type**, and **content** (or **content-url**)?  If not, parsing fails.

3. Some level of sanity check should be made on *JSONSCAN version number* and the format -- does the application support this version, etc.

4. Sanity check on *type value* -- does the application know what to do with it?  Is there a whitelist/graylist/blacklist mechanism which prevents accessing certain types, urls, manually vs automatically, etc.?  Does it have permission to call out to a helper app?  and so on....

5. If it knows what to do with the type/content combination -- do it!  If it has multiple options, present user with a choice.


### Caveats and Considerations ###

1. Perhaps some types might be "inherit" from other types.  A "photo" might be considered a more specific version of "image", etc.

2. Can both _content_ and _content-url_ be presented?  If so, which is favorable? If connectivity fails, fall back to local?  Use local as a "preview" until remote content is retrieved?

3. Security, security, security.


Examples
--------

(links to actual json files go here)

