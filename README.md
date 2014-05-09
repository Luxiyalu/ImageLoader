EasyImage
====

### Load image with:

1. image tag
2. canvas
2. background

### Example
normal:
```html
<div class="emg" data-src="arrow.png" data-type="img" data-alt=""></div>
```
with built-in media-query (identified by string "{media}"):
```html
<div class="emg" data-src="arrow-{media}.png" data-type="bg"></div>
```

### data-type could be:

1. img (default)
2. cvs (todo)
3. bg
4. auto (todo)
load with canvas on default, change to img tag on mobile devices

## Events

1. start
```javascript
Emg.on("start", function(){
	//do things on start
});
```
2. update
```javascript
Emg.on("update", function(){
	//do things on update
});
```
3. complete
```javascript
Emg.on("complete", function(){
	//do things on complete
});
```

## Options

1. divide
Must be set together with "naming"
2. naming
```javascript
Emg.init({
	divide: [320, 499],
	naming: ['small', 'medium', 'large']
});
```
Combined with:
```html
<div class="emg" data-type="bg" data-src="arrow-{media}.png"></div>
```
Will provide a background picture that changes its background image url to "arrow-small.png" with a width below 320px, "arrow-medium.png" below 499px and "arrow-large.png" above 499px.
3. defaultType
The default load type, could be: "img", "bg", "cvs".
```javascript
Emg.init({defaultType: "img"});
```

## Todo
canvas
