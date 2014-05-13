ImageLoader
====

##### ImageLoader provides:

1. javascript image loading (with image tag, canvas or background-image)
2. load different images on window resize
2. a loading percentage

### Install

```
bower install imageloader
```

ImageLoader depends on jQuery, and running the above line would automatically install jQuery.

### Usage

**Html:**
```html
<div class="image-loader" data-src="arrow.png" data-type="img" data-alt=""></div>
```
Data-type could be: <code>img</code>, <code>cvs</code> and <code>bg</code>. If not specified in <code>data-type</code>, image will load through image tags by default.

**JavaScript:**
```javascript
ImageLoader.init();
```

### Options

**1. divide**

Must be set together with <code>naming</code>.

**2. naming**

```javascript
ImageLoader.init({
	divide: [320, 499],
	naming: ['small', 'medium', 'large']
});
```
Combined with:
```html
<div class="emg" data-type="bg" data-src="arrow-{media}.png"></div>
```
Will provide a div that changes its background image url to "arrow-small.png" with a width below 320px, "arrow-medium.png" below 499px and "arrow-large.png" above 499px.

**3. defaultType**

The default image load type, could be: <code>img</code>, <code>bg</code>, <code>cvs</code>.

```javascript
Emg.init({defaultType: "cvs"});
```
Load images by canvas if attribute <code>data-type</code> is not specified.

### Values

**1. ImageLoader.currentNum**

Current loading percentage, e.g. <code>63</code>.

**2. ImageLoader.length**

The number of all the images loading through ImageLoader.

### Events

**1. start**

```javascript
ImageLoader.on("start", function(){
	//do things on start
});
```

**2. update**

```javascript
ImageLoader.on("update", function(){
	//do things on update, e.g., update layout according to loading percentage
});
```

**3. complete**

```javascript
ImageLoader.on("complete", function(){
	//do things on complete, e.g., loading disappear, page appear
});
```

## Todo

1. load through canvas
2. <code>data-typt="auto"</code>: load with canvas on default, change to img tag on mobile devices

