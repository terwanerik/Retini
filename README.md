![alt text](https://github.com/terwanerik/Retini/blob/master/Images/Icon%7E256.png "Retini")
# Retini
A super fast and simple retina (@2x, @3x) image converter.

## How to use?
You can download the [prebuilt application from the releases](https://github.com/terwanerik/Retini/releases), or just download / fork the project and build it yourself.

After you've got the app running, you can drag single files, multiple files and directories to convert @3x or @2x images. Dragging is allowed in the Retini window as well as the App Icon in the Dock.

## How does it work?

The resized images will be placed in the same directory as the source file. The resizing goes like this:

| Generated? | Drag @3x file | Drag @2x file |
|------------|---------------|---------------|
| @2x        | &radic;       | &times;       |
| 1x         | &radic;       | &radic;       |

The original file will never be altered, the `@2x` and `1x` are copies. If you drag a `@3x` file, the `1x` file generated will be generated from the (original) `@3x`, so no double conversion loss.

### Pixel art upscaling
You can drag a file with a `@1x` extension, Retini will scale this to a `@2x` and `@3x` file. This is nice for pixel art, upscaling is done via the nearest neighboor filter / algorithm.
