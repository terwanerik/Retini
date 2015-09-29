![alt text](https://github.com/terwanerik/Retini/blob/master/Images/Icon%7E256.png "Retini")
# Retini
A super fast and simple retina (@2x, @3x) image converter.

## How to use?
You can download the [prebuilt application from this link](https://github.com/terwanerik/Retini/raw/master/Retini.zip), or just download / fork the project and built it yourself.

After you've got the app running, you can drag single files, multiple files and directories to convert @3x or @2x images. Dragging is allowed in the Retini window aswell as the App Icon in the Dock.

## How does it work?

The resized images will be placed in the same directory as the source file. The resizing goes like this:

| Generated? | Drag @3x file | Drag @2x file |
|------------|---------------|---------------|
| @2x        | yes           | no            |
| 1x         | yes           | yes           |

The original file will never be altered, the `@2x` and `1x` are copies. If you drag a `@3x` file the `1x` file generated will be generated from the (original) `@3x`.
