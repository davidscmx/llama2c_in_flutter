import 'dart:ffi' as ffi;
import 'dart:io' show Platform, Directory;
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

// FFI signature of the llama2c C function
typedef Llama2cFunc = ffi.Void Function(
    ffi.Int32 argc, ffi.Pointer<ffi.Pointer<ffi.Int8>> argv);
// Dart type definition for calling the C foreign function
typedef Llama2c = void Function(
    int argc, ffi.Pointer<ffi.Pointer<ffi.Int8>> argv);

void main() {
  // Open the dynamic library
  var libraryPath =
      path.join(Directory.current.path, 'llama2.c', 'libllama2c.so');

  if (Platform.isMacOS) {
    libraryPath = path.join(
        Directory.current.path, 'llama2c_package/llama2.c', 'libllama2c.dylib');
  }

  if (Platform.isWindows) {
    libraryPath = path.join(Directory.current.path, 'llama2c_package/llama2.c',
        'Debug', 'llama2c.dll');
  }

  final dylib = ffi.DynamicLibrary.open(libraryPath);

  // Look up the C function 'llama2c'
  final Llama2c llama2c =
      dylib.lookup<ffi.NativeFunction<Llama2cFunc>>('llama2c').asFunction();

  // Convert the Dart list of strings to a C array of strings (Utf8)
  final List<String> args = [
    'llama2.c/stories110M.bin', // checkpoint_path
    //'-t', '1.0', // temperature
    //'-p', '0.9', // topp
    //'-s', '12345', // rng_seed
    //'-n', '256', // steps
    //'-i', 'Hello, world!', // prompt
    //'-z', 'my_tokenizer.bin', // tokenizer_path
    //'-m', 'chat', // mode
    //'-y', 'System prompt' // system_prompt
  ];

  print('Args: $args');

  final argv = calloc<ffi.Pointer<ffi.Int8>>(args.length);
  for (var i = 0; i < args.length; i++) {
    argv[i + 1] = args[i].toNativeUtf8().cast<ffi.Int8>();
    print('argv[$i] in dart = ${args[i]}');
  }

  // Call the function with arguments
  llama2c(args.length + 1, argv);

  // Don't forget to free the C strings and the array after you're done with them
  for (var i = 0; i < args.length; i++) {
    calloc.free(argv[i]);
  }
  calloc.free(argv);
}
