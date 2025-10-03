// PuzzleGame widget - Fixed and Responsive
// - Images hardcoded in list, chosen randomly by pressing a button
// - Score saved in Hive
// - Score calculated based on solve time (faster = higher score)
// - Works with any image size/aspect ratio

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nasa_app/generated/l10n.dart';

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  int gridSize = 3;
  int moves = 0;
  int score = 0;
  int timeElapsed = 0;

  Timer? timer;
  late List<int> tiles;
  final rng = Random();

  final List<String> images = [
    'assets/images/puzzle1.png',
    'assets/images/puzzle2.jpg',
  ];
  String currentImage = 'assets/images/puzzle1.png';

  @override
  void initState() {
    super.initState();
    _loadScore();
    _newPuzzle();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadScore() async {
    try {
      var box = await Hive.openBox('puzzle');
      if (mounted) {
        setState(() {
          score = box.get('score', defaultValue: 0);
        });
      }
    } catch (e) {
      debugPrint('Error loading score: $e');
    }
  }

  Future<void> _saveScore() async {
    try {
      var box = await Hive.openBox('puzzle');
      await box.put('score', score);
    } catch (e) {
      debugPrint('Error saving score: $e');
    }
  }

  void _startTimer() {
    timer?.cancel();
    timeElapsed = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        timeElapsed++;
      });
    });
  }

  void _newPuzzle() {
    final n = gridSize * gridSize;
    tiles = List<int>.generate(n, (i) => i);
    do {
      tiles.shuffle(rng);
    } while (!_isSolvable(tiles) || _isSolved(tiles));
    moves = 0;
    timer?.cancel();
    _startTimer();
    if (mounted) setState(() {});
  }

  bool _isSolved(List<int> t) {
    for (var i = 0; i < t.length; i++) {
      if (t[i] != i) return false;
    }
    return true;
  }

  bool _isSolvable(List<int> array) {
    final n = gridSize;
    final list = array.where((e) => e != (n * n - 1)).toList();
    int inv = 0;
    for (int i = 0; i < list.length; i++) {
      for (int j = i + 1; j < list.length; j++) {
        if (list[i] > list[j]) inv++;
      }
    }
    if (n.isOdd) {
      return inv.isEven;
    } else {
      final emptyRowFromBottom = n - (array.indexOf(n * n - 1) ~/ n);
      if (emptyRowFromBottom.isEven) return inv.isOdd;
      return inv.isEven;
    }
  }

  int _calculateScore() {
    // Base score increases exponentially with difficulty
    // 3x3: 1500, 4x4: 3000, 5x5: 5000, 6x6: 8000
    int baseScore = gridSize * gridSize * 150;

    // Difficulty multiplier: higher grid = higher multiplier
    double difficultyMultiplier = 1.0 + ((gridSize - 3) * 0.5);

    // Time penalty: lose points for taking longer
    // Formula: faster solve = higher score
    // Perfect time expectations: 3x3=30s, 4x4=60s, 5x5=120s, 6x6=180s
    int perfectTime = (gridSize - 2) * 30;
    int timePenalty = max(0, (timeElapsed - perfectTime) * 5);

    // Move penalty: lose points for extra moves
    // Optimal moves estimate: roughly (gridSize^2 - 1) * 2
    int optimalMoves = (gridSize * gridSize - 1) * 2;
    int movePenalty = max(0, (moves - optimalMoves) * 10);

    // Calculate final score with difficulty multiplier (minimum 100)
    int finalScore = max(
      100,
      ((baseScore - timePenalty - movePenalty) * difficultyMultiplier).round(),
    );

    return finalScore;
  }

  void _onTileTap(int index) {
    final emptyIndex = tiles.indexOf(gridSize * gridSize - 1);
    final neighbors = _getNeighbors(emptyIndex);
    if (neighbors.contains(index)) {
      setState(() {
        tiles[emptyIndex] = tiles[index];
        tiles[index] = gridSize * gridSize - 1;
        moves++;
      });
      if (_isSolved(tiles)) {
        timer?.cancel();
        int gained = _calculateScore();
        setState(() {
          score += gained;
        });
        _saveScore();
        _showWinDialog(gained);
      }
    }
  }

  List<int> _getNeighbors(int idx) {
    final row = idx ~/ gridSize;
    final col = idx % gridSize;
    final List<int> res = [];
    if (row > 0) res.add((row - 1) * gridSize + col);
    if (row < gridSize - 1) res.add((row + 1) * gridSize + col);
    if (col > 0) res.add(row * gridSize + (col - 1));
    if (col < gridSize - 1) res.add(row * gridSize + (col + 1));
    return res;
  }

  void _changeImage() {
    setState(() {
      String newImage;
      do {
        newImage = images[rng.nextInt(images.length)];
      } while (newImage == currentImage && images.length > 1);

      currentImage = newImage;
      gridSize = 3;
      _newPuzzle();
    });
  }

  void _showWinDialog(int gained) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 You Win!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${_formatTime(timeElapsed)}'),
            Text('Moves: $moves'),
            const Divider(),
            Text(
              'Score gained: +$gained',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          if (gridSize < 6)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                gridSize++;
                _newPuzzle();
              },
              child: const Text('Next Level'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _newPuzzle();
            },
            child: Text(gridSize < 6 ? 'Replay' : 'New Puzzle'),
          ),
        ],
      ),
    );
  }

  /// A* solver for the sliding puzzle. Returns a list of tile indices to TAP
  /// in the current board sequence to reach the solved state (or null if no solution
  /// within maxExplored).
  List<int>? solveAStar(List<int> start, int n, {int maxExplored = 200000}) {
    final goal = List<int>.generate(n * n, (i) => i);
    final goalKey = goal.join(',');
    String keyOf(List<int> s) => s.join(',');

    int manhattan(List<int> state) {
      int h = 0;
      for (int i = 0; i < state.length; i++) {
        final v = state[i];
        if (v == n * n - 1) continue; // skip blank
        final curR = i ~/ n;
        final curC = i % n;
        final goalR = v ~/ n;
        final goalC = v % n;
        h += (curR - goalR).abs() + (curC - goalC).abs();
      }
      return h;
    }

    // neighbors: swap blank with each neighbor
    List<List<int>> neighborsOf(List<int> s) {
      final blank = s.indexOf(n * n - 1);
      final r = blank ~/ n;
      final c = blank % n;
      final res = <List<int>>[];
      void addSwap(int nr, int nc) {
        final idx = nr * n + nc;
        final copy = List<int>.from(s);
        final tmp = copy[idx];
        copy[idx] = copy[blank];
        copy[blank] = tmp;
        res.add(copy);
      }

      if (r > 0) addSwap(r - 1, c);
      if (r < n - 1) addSwap(r + 1, c);
      if (c > 0) addSwap(r, c - 1);
      if (c < n - 1) addSwap(r, c + 1);
      return res;
    }

    // Simple priority queue using list (OK for 3x3). Each entry: (f, g, state)
    final open = <Map<String, dynamic>>[];
    final startKey = keyOf(start);
    open.add({'f': manhattan(start), 'g': 0, 'key': startKey, 'state': start});

    final gScore = <String, int>{startKey: 0};
    final parent = <String, String>{};

    int explored = 0;

    while (open.isNotEmpty) {
      // pop smallest f
      open.sort((a, b) => (a['f'] as int).compareTo(b['f'] as int));
      final node = open.removeAt(0);
      final curKey = node['key'] as String;
      final curState = List<int>.from(node['state'] as List<int>);
      final curG = node['g'] as int;

      explored++;
      if (explored > maxExplored) return null; // give up

      if (curKey == goalKey) {
        // reconstruct path of states
        var pathKeys = <String>[];
        String k = curKey;
        while (parent.containsKey(k)) {
          pathKeys.add(k);
          k = parent[k]!;
        }
        pathKeys.add(k);
        pathKeys = pathKeys.reversed.toList();

        // convert states to list of taps (indices to tap in each intermediate state)
        final states = pathKeys
            .map((s) => s.split(',').map(int.parse).toList())
            .toList();
        final taps = <int>[];
        for (int i = 0; i < states.length - 1; i++) {
          final next = states[i + 1];
          // final blankPrev = prev.indexOf(n * n - 1);
          final blankNext = next.indexOf(n * n - 1);
          // the tile to tap in prev is at index blankNext (the neighbor that swapped with blank)
          taps.add(blankNext);
        }
        return taps;
      }

      // expand
      final neighs = neighborsOf(curState);
      for (final nb in neighs) {
        final nbKey = keyOf(nb);
        final tentativeG = curG + 1;
        if (!gScore.containsKey(nbKey) || tentativeG < gScore[nbKey]!) {
          gScore[nbKey] = tentativeG;
          parent[nbKey] = curKey;
          final f = tentativeG + manhattan(nb);
          // add to open
          open.add({'f': f, 'g': tentativeG, 'key': nbKey, 'state': nb});
        }
      }
    }

    return null; // no solution found
  }

  /// Debug helper: run the solver and automatically apply moves with a small delay.
  /// Example usage: await autoSolve(); // uses current `tiles` and `gridSize`
  Future<void> autoSolve({int stepDelayMs = 300}) async {
    if (gridSize > 4) return;
    if (!_isSolvable(tiles)) {
      debugPrint('Puzzle not solvable');
      return;
    }

    final taps = solveAStar(List<int>.from(tiles), gridSize);
    if (taps == null) {
      debugPrint('No solution found (limit reached)');
      return;
    }

    for (final idx in taps) {
      // wait a bit so you can see the moves, and then tap
      await Future.delayed(Duration(milliseconds: stepDelayMs));
      if (!mounted) return;
      // idx is the index to tap in the current board state
      _onTileTap(idx);
    }
  }

  void _showGridSizeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Choose Grid Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int size = 3; size <= 6; size++)
              ListTile(
                leading: Icon(
                  Icons.grid_4x4,
                  color: gridSize == size ? Colors.blue : Colors.grey,
                ),
                title: Text(
                  '${size}x$size',
                  style: TextStyle(
                    fontWeight: gridSize == size
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: gridSize == size ? Colors.blue : Colors.black,
                  ),
                ),
                subtitle: Text(_getDifficultyLabel(size)),
                onTap: () {
                  Navigator.pop(context);
                  if (gridSize != size) {
                    setState(() {
                      gridSize = size;
                      _newPuzzle();
                    });
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  String _getDifficultyLabel(int size) {
    switch (size) {
      case 3:
        return 'Easy - 1.0x multiplier';
      case 4:
        return 'Medium - 1.5x multiplier';
      case 5:
        return 'Hard - 2.0x multiplier';
      case 6:
        return 'Expert - 2.5x multiplier';
      default:
        return '';
    }
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildBoard(double size) {
    final tileSize = size / gridSize;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: List.generate(gridSize * gridSize, (i) {
            final tileValue = tiles[i];
            final row = i ~/ gridSize;
            final col = i % gridSize;
            final left = col * tileSize;
            final top = row * tileSize;
            final isEmpty = tileValue == gridSize * gridSize - 1;

            return AnimatedPositioned(
              left: left,
              top: top,
              width: tileSize,
              height: tileSize,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: GestureDetector(
                onTap: isEmpty ? null : () => _onTileTap(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isEmpty ? Colors.transparent : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: isEmpty
                        ? const SizedBox.shrink()
                        : _TileImage(
                            imagePath: currentImage,
                            gridSize: gridSize,
                            index: tileValue,
                          ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).puzzleGame,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isPortrait = constraints.maxHeight > constraints.maxWidth;
            final boardSize = isPortrait
                ? min(constraints.maxWidth * 0.9, constraints.maxHeight * 0.6)
                : min(constraints.maxHeight * 0.7, constraints.maxWidth * 0.5);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Stats row
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatItem(
                              icon: Icons.grid_4x4,
                              label: 'Level',
                              value: '${gridSize}x$gridSize',
                              color: Colors.black,
                            ),
                            _StatItem(
                              icon: Icons.star,
                              label: 'Score',
                              value: '$score',
                              color: Colors.black,
                            ),
                            _StatItem(
                              icon: Icons.timer,
                              label: 'Time',
                              value: _formatTime(timeElapsed),
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Game board
                    Center(child: _buildBoard(boardSize)),
                    const SizedBox(height: 20),
                    // Moves counter
                    Text(
                      '${S.of(context).moves}: $moves',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    // Controls
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _changeImage,
                          icon: const Icon(Icons.shuffle),
                          label: Text(S.of(context).randomImage),
                        ),
                        ElevatedButton.icon(
                          onPressed: _newPuzzle,
                          icon: const Icon(Icons.refresh),
                          label: Text(S.of(context).newPuzzle),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showGridSizeDialog,
                          icon: const Icon(Icons.edit),
                          label: Text(S.of(context).chooseGridSize),
                        ),
                        if (kDebugMode)
                          ElevatedButton.icon(
                            onPressed: autoSolve,
                            icon: const Icon(Icons.edit),
                            label: Text(S.of(context).solve),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.black),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.black),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}

class _TileImage extends StatelessWidget {
  final String imagePath;
  final int gridSize;
  final int index;

  const _TileImage({
    required this.imagePath,
    required this.gridSize,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final row = index ~/ gridSize;
    final col = index % gridSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 0,
          minHeight: 0,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Transform.translate(
            offset: Offset(-col * w, -row * h),
            child: SizedBox(
              width: w * gridSize,
              height: h * gridSize,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[600],
                        size: min(w, h) * 0.5,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
