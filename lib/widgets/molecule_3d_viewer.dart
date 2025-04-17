import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../providers/compound_provider.dart';

class Molecule3DViewer extends StatefulWidget {
  final int cid;
  final double height;
  final Function(WebViewController)? onWebViewCreated;

  const Molecule3DViewer({
    Key? key,
    required this.cid,
    this.height = 300,
    this.onWebViewCreated,
  }) : super(key: key);

  @override
  State<Molecule3DViewer> createState() => _Molecule3DViewerState();
}

class _Molecule3DViewerState extends State<Molecule3DViewer> {
  late WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _loadMoleculeData();
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _error = 'Failed to load 3D viewer: ${error.description}';
              });
            }
          },
        ),
      );

    // Platform specific settings
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setOnPlatformPermissionRequest(
            (PlatformWebViewPermissionRequest request) {
          request.grant();
        });
    }

    _controller.loadHtmlString(_get3DMolHTML());

    // Notify parent widget about WebView creation
    if (widget.onWebViewCreated != null) {
      widget.onWebViewCreated!(_controller);
    }
  }

  Future<void> _loadMoleculeData() async {
    try {
      final provider = Provider.of<CompoundProvider>(context, listen: false);

      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      // Fetch the SDF data for the compound
      final sdfData = await provider.fetch3DStructure(widget.cid);

      // Escape any quotes in the SDF data to avoid JavaScript issues
      final escapedSDF = sdfData.replaceAll('"', '\\"').replaceAll('\n', '\\n');

      // Execute JavaScript to load the molecule data into the 3Dmol viewer
      await _controller.runJavaScript('''
        try {
          let viewer = \$3Dmol.viewers.viewer_3dmol;
          viewer.clear();
          viewer.addModel("$escapedSDF", "sdf");
          viewer.setBackgroundColor(0xffffff, 0.0);
          viewer.setStyle({}, {"stick": {}, "sphere": {"scale": 0.3}});
          viewer.zoomTo();
          viewer.render();
          true;
        } catch (e) {
          console.error("Error loading molecule data:", e);
          false;
        }
      ''').then((value) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = 'Error rendering molecule: $error';
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load molecule data: $e';
        });
      }
    }
  }

  // Generate HTML with embedded 3Dmol.js
  String _get3DMolHTML() {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <title>3D Molecule Viewer</title>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/3Dmol/2.0.3/3Dmol-min.js"></script>
        <style>
          body {
            margin: 0;
            padding: 0;
            overflow: hidden;
            width: 100%;
            height: 100%;
            background-color: transparent;
            -webkit-touch-callout: none;
            -webkit-user-select: none;
            user-select: none;
          }
          #viewer {
            position: absolute;
            width: 100%;
            height: 100%;
            transform: translateZ(0);
            -webkit-transform: translateZ(0);
          }
        </style>
      </head>
      <body>
        <div id="viewer"></div>
        <script>
          \$(document).ready(function() {
            let config = {
              backgroundColor: 'transparent',
              antialias: true,
              quality: 'medium',
              defaultcolors: \$3Dmol.rasmolElementColors,
              styles: {
                stick: {
                  radius: 0.2,
                  singleBonds: true,
                  linewidth: 1
                },
                sphere: {
                  scale: 0.3
                }
              }
            };
            window.\$3Dmol.viewers.viewer_3dmol = \$3Dmol.createViewer(
              document.getElementById('viewer'), 
              config
            );
          });
        </script>
      </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // WebView for 3D rendering
          WebViewWidget(controller: _controller),

          // Loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Error message
          if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadMoleculeData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class Molecule3DControls extends StatelessWidget {
  final WebViewController? controller;
  final VoidCallback onReset;

  const Molecule3DControls({
    Key? key,
    this.controller,
    required this.onReset,
  }) : super(key: key);

  void _executeRotation(String direction) {
    if (controller == null) return;

    String jsCommand;
    switch (direction) {
      case 'left':
        jsCommand = 'viewer.rotate(0.3, {y:1});';
        break;
      case 'right':
        jsCommand = 'viewer.rotate(-0.3, {y:1});';
        break;
      case 'up':
        jsCommand = 'viewer.rotate(0.3, {x:1});';
        break;
      case 'down':
        jsCommand = 'viewer.rotate(-0.3, {x:1});';
        break;
      case 'reset':
        jsCommand = 'viewer.zoomTo();';
        break;
      default:
        return;
    }
    controller!.runJavaScript('''
      try {
        let viewer = \$3Dmol.viewers.viewer_3dmol;
        $jsCommand
        viewer.render();
      } catch (e) {
        console.error("Error rotating molecule:", e);
      }
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.rotate_left),
            onPressed:
                controller == null ? null : () => _executeRotation('left'),
            tooltip: 'Rotate Left',
          ),
          IconButton(
            icon: const Icon(Icons.rotate_right),
            onPressed:
                controller == null ? null : () => _executeRotation('right'),
            tooltip: 'Rotate Right',
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            onPressed: controller == null ? null : () => _executeRotation('up'),
            tooltip: 'Rotate Up',
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed:
                controller == null ? null : () => _executeRotation('down'),
            tooltip: 'Rotate Down',
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: controller == null
                ? null
                : () {
                    _executeRotation('reset');
                    onReset();
                  },
            tooltip: 'Reset View',
          ),
        ],
      ),
    );
  }
}

class Complete3DMoleculeViewer extends StatefulWidget {
  final int cid;

  const Complete3DMoleculeViewer({
    Key? key,
    required this.cid,
  }) : super(key: key);

  @override
  State<Complete3DMoleculeViewer> createState() =>
      _Complete3DMoleculeViewerState();
}

class _Complete3DMoleculeViewerState extends State<Complete3DMoleculeViewer> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _error;

  void _onWebViewCreated(WebViewController controller) {
    // Use a post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _controller = controller;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.view_in_ar,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '3D Structure',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                  },
                  tooltip: 'Reload 3D Structure',
                ),
              ],
            ),
          ),

          // 3D Viewer
          SizedBox(
            height: 300,
            child: Molecule3DViewer(
              cid: widget.cid,
              onWebViewCreated: _onWebViewCreated,
            ),
          ),

          // Controls
          Molecule3DControls(
            controller: _controller,
            onReset: () {
              // Reset logic if needed
            },
          ),
        ],
      ),
    );
  }
}
