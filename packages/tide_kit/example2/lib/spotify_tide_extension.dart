import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify/spotify.dart' as spotify;
import 'package:tide_kit/tide_kit.dart';

/// A Tide extension that uses the keybinding and time services, and adds a keybinding to toggle the
/// status bar visibility.
class SpotifyTideExtension extends TideExtension {
  SpotifyTideExtension();

  @override
  TideId get id => const TideId('spotify.tide.extension');

  @override
  String get uuid => '110ec58a-a0f2-4ac4-8393-c866d813b8d1';

  @override
  String get name => 'Spotify Tide Extension';

  /// The panel ID where the spotify search pane is displayed.
  final panelId = const TideId('spotify.search.panel');

  static const togglePanelVisibility =
      TideId('spotify.command.toggleSearchPanelVisibility');

  static const focusSearchField = TideId('spotify.command.focusSearchField');

  /// Spotify service
  SpotifyService spotifyService = SpotifyService();

  @override
  void activate(Tide tide) {
    tide.useServices(services: [Tide.ids.service.keybindings]);

    final FocusNode searchFieldFocusNode = FocusNode();

    // Spotify setup
    spotifyService.initialize();

    Tide.registerCommandContribution(
      TideTogglePanelVisibilityContribution(
          commandId: togglePanelVisibility, panelId: panelId),
    );

    Tide.registerCommandContribution(
      TideShowPanelAndFocusContribution(
          commandId: focusSearchField,
          panelId: panelId,
          focusNode: searchFieldFocusNode),
    );

    final selectedItem = ValueNotifier<Object?>(null);
    final selectedTracks = ValueNotifier<Iterable<spotify.Track>?>(null);

    tide.workbenchService.layoutService.addPanel(TidePanel(
      panelId: panelId,
      panelBuilder: (context, panel) {
        return TidePanelWidget(
          panelId: panel.panelId,
          backgroundColor: const Color(0xFFF3F3F3),
          position: TidePosition.left,
          resizeSide: TidePosition.right,
          minWidth: 150,
          maxWidth: 450,
          initialWidth: 220,
          child: TideSearchPanel(
            searchFieldFocusNode: searchFieldFocusNode,
            onChanged: (value) {
              spotifyService.search(value);
            },
            results: SpotifySearchResults(
              spotifyService: spotifyService,
              onSelected: (item) {
                selectedItem.value = item;
                selectedTracks.value = null;
                if (item is spotify.Artist && item.id != null) {
                  Future.delayed(Duration.zero, () async {
                    selectedTracks.value =
                        await spotifyService.loadArtistTopTracks(item.id!);
                  });
                } else if (item is spotify.PlaylistSimple && item.id != null) {
                  Future.delayed(Duration.zero, () async {
                    selectedTracks.value =
                        await spotifyService.loadPlaylist(item.id!);
                  });
                  // } else if (item is spotify.Playlist && item.id != null) {
                  //   Future.delayed(Duration.zero, () async {
                  //     selectedTracks.value =
                  //         await spotifyService.loadArtistTopTracks(item.id!);
                  //   });
                }
              },
            ),
          ),
        );
      },
    ));

    tide.workbenchService.layoutService.addPanel(TidePanel(
      panelId: const TideId('spotify.content.panel'),
      panelBuilder: (context, panel) {
        return TidePanelWidget(
          backgroundColor: Colors.white,
          expanded: true,
          minWidth: 150,
          position: TidePosition.center,
          child: ValueListenableBuilder<Object?>(
              valueListenable: selectedItem,
              builder: (context, state, child) {
                return ValueListenableBuilder<Object?>(
                    valueListenable: selectedTracks,
                    builder: (context, state, child) {
                      return SpotifyContentPanel(
                        spotifyService: spotifyService,
                        item: selectedItem.value != null
                            ? SpotifyObject(item: selectedItem.value!)
                            : null,
                        tracks: selectedTracks.value,
                      );
                    });
              }),
        );
      },
    ));

    // tide.workbenchService.layoutService.addActivityBarItems([
    //   TideActivityBarItem(
    //     title: 'Calendar Day',
    //     icon: Icons.calendar_month,
    //     commandId: togglePanelVisibility,
    //   ),
    // ]);

    // tide.workbenchService.layoutService.addStatusBarItem(TideStatusBarItemTime(
    //   position: TideStatusBarItemPosition.left,
    //   use24HourFormat: true,
    // ));

    final bindings = Tide.get<TideKeybindingService>();

    // Add shortcuts / bindings / hotkeys

    // Add binding: shift-meta-F (shift-command-F) to toggle the search panel bar visibility.
    bindings.addBinding(
      TideKeybinding(
          keySet: LogicalKeySet(LogicalKeyboardKey.shift,
              LogicalKeyboardKey.meta, LogicalKeyboardKey.keyF),
          commandId: togglePanelVisibility),
    );

    // Add binding: meta-F (command-F) to open the search panel bar and focus the search input.
    bindings.addBinding(
      TideKeybinding(
          keySet:
              LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyF),
          commandId: focusSearchField),
    );
  }
}

class SpotifySearchResults extends StatefulWidget {
  const SpotifySearchResults(
      {super.key, required this.spotifyService, this.onSelected});

  final SpotifyService spotifyService;

  final void Function(Object? item)? onSelected;

  @override
  State<SpotifySearchResults> createState() => _SpotifySearchResultsState();
}

class _SpotifySearchResultsState extends State<SpotifySearchResults> {
  Object? _selectedItem;
  Object? _hoverItem;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SpotifyServiceState>(
      valueListenable: widget.spotifyService.state,
      builder: (context, state, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Text(
                  '${state.searchResults.length} results in ${state.typesCount} types',
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13.0,
                      fontWeight: FontWeight.normal)),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: state.searchResults.length,
                itemBuilder: (context, index) {
                  final item = state.searchResults[index];
                  return SpotifySearchResultItem(
                    item: SpotifyObject(item: item),
                    hovering: _hoverItem == item,
                    isItemSelected: _selectedItem == item,
                    onHover: (value) {
                      setState(() => _hoverItem = value ? item : null);
                    },
                    onTap: () {
                      if (_selectedItem == item) {
                        setState(() => _selectedItem = null);
                      } else {
                        setState(() => _selectedItem = item);
                      }
                      widget.onSelected?.call(item);
                    },
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }
}

class SpotifyCircularNetworkImage extends StatelessWidget {
  const SpotifyCircularNetworkImage(
      {super.key, required this.imageUrl, required this.size});

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          }
        },
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          return Icon(
            Icons.error,
            size: size,
          );
        },
      ),
    );
  }
}

class SpotifyNetworkImage extends StatelessWidget {
  const SpotifyNetworkImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        }
      },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return const Icon(Icons.error, size: 40.0);
      },
    );
  }
}

class SpotifyContentPanel extends StatelessWidget {
  const SpotifyContentPanel(
      {super.key, required this.spotifyService, this.item, this.tracks});

  final SpotifyService spotifyService;
  final SpotifyObject? item;
  final Iterable<spotify.Track>? tracks;

  @override
  Widget build(BuildContext context) {
    if (item == null) return const SizedBox.shrink();

    final firstImage =
        item!.images?.isNotEmpty == true ? item!.images?.last.url : null;
    final smallImage = firstImage != null
        ? SpotifyCircularNetworkImage(imageUrl: firstImage, size: 80.0)
        : const Icon(
            Icons.account_circle_outlined,
            size: 100.0, // Adjust the size as needed
            color: Colors.blue, // Adjust the color as needed
          );

    String subtitle = '';
    if (item!.item is spotify.Artist) {
      subtitle = 'Artist';
    } else if (item!.item is spotify.PlaylistSimple) {
      subtitle = 'Playlist';
    } else if (item!.item is spotify.Playlist) {
      subtitle = 'Playlist';
    }

    final top = Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          smallImage,
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item?.name ?? '',
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal)),
              ],
            ),
          ),
        ],
      ),
    );

    final trackList = tracks?.map((track) {
      final imageUrl = track.album?.images?.last.url;
      final image = imageUrl != null
          ? ClipRRect(
              borderRadius:
                  BorderRadius.circular(4.0), // Adjust the radius as needed
              child: SizedBox(
                  width: 48.0,
                  height: 48.0,
                  child: SpotifyNetworkImage(imageUrl: imageUrl)),
            )
          : const Icon(Icons.album_outlined, size: 40.0);

      return ListTile(
        leading: image,
        title: Text(track.name ?? '',
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 16.0,
                fontWeight: FontWeight.normal)),
        subtitle: Text(item!.durationFormatted(track.duration ?? Duration.zero),
            style: const TextStyle(
                color: Colors.black45,
                fontSize: 14.0,
                fontWeight: FontWeight.normal)),
      );
    }).toList();

    final middle = [
      const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text('Popular',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold))),
      if (trackList != null) ...trackList,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        top,
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: middle,
            ),
          ),
        ),
      ],
    );
  }
}

class SpotifySearchResultItem extends StatelessWidget {
  const SpotifySearchResultItem(
      {super.key,
      required this.item,
      this.hovering = false,
      this.isItemSelected = false,
      this.onHover,
      this.onTap});

  final SpotifyObject item;
  final bool hovering;
  final bool isItemSelected;

  /// Called when a pointer enters or exits the item.
  final ValueChanged<bool>? onHover;

  /// Called when the user taps this item.
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final title = item.name;
    final subtitle = item.type;

    return InkWell(
      onHover: onHover,
      onTap: onTap,
      child: Container(
        color: isItemSelected
            ? const Color(0xFFE4E6F1)
            : hovering
                ? const Color(0xFFE8E8E8)
                : Colors.transparent,
        padding: const EdgeInsets.only(
            left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal)),
            Text(
              subtitle.capitalize(),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 12.0,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}

class SpotifyServiceState {
  const SpotifyServiceState(
      {this.searchResults = const [], this.typesCount = 0});

  final List<Object> searchResults;
  final int typesCount;
}

class SpotifyService {
  SpotifyService() {
    Tide.log('SpotifyService created');
  }

  final state = ValueNotifier(const SpotifyServiceState());

  late spotify.SpotifyApi _spotify;

  void initialize() {
    Tide.log('SpotifyService.initialize');

    const clientId = 'd7c4ce7c172041b8b63ef73e2afe9e3e';
    const clientSecret = 'cce6f1b7c3e7408f96478aade2fb050c';
    final credentials = spotify.SpotifyApiCredentials(clientId, clientSecret);
    _spotify = spotify.SpotifyApi(credentials);
  }

  void updateState(SpotifyServiceState newState) {
    state.value = newState;
  }

  Future<Iterable<spotify.Track>> loadArtistTopTracks(String artistId) async {
    final topTracks =
        await _spotify.artists.topTracks(artistId, spotify.Market.US);
    return topTracks;
  }

  Future<Iterable<spotify.Track>> loadPlaylist(String playlistId) async {
    final playlist =
        await _spotify.playlists.getTracksByPlaylistId(playlistId).all();
    return playlist;
  }

  Future<void> search(String query) async {
    List<Object> searchResults = [];
    updateState(SpotifyServiceState(searchResults: searchResults));
    if (query.isEmpty) return;

    final search = await _spotify.search.get(query, types: [
      spotify.SearchType.artist,
      spotify.SearchType.playlist
    ]).first();

    Set<Object> types = {};

    for (final pages in search) {
      for (final item in pages.items!) {
        searchResults.add(item);
        types.add(item.runtimeType);
      }
    }

    updateState(SpotifyServiceState(
        searchResults: searchResults, typesCount: types.length));
  }
}

class SpotifyObject {
  SpotifyObject({required this.item});

  final Object item;

  String get name {
    final name = item is spotify.Artist
        ? (item as spotify.Artist).name
        : item is spotify.Playlist
            ? (item as spotify.Playlist).name
            : item is spotify.PlaylistSimple
                ? (item as spotify.PlaylistSimple).name
                : '***';
    return name ?? '';
  }

  String get type {
    final type = item is spotify.Artist
        ? (item as spotify.Artist).type.toString()
        : item is spotify.Playlist
            ? (item as spotify.Playlist).type.toString()
            : item is spotify.PlaylistSimple
                ? (item as spotify.PlaylistSimple).type.toString()
                : '***';
    return type;
  }

  List<spotify.Image>? get images {
    final images = item is spotify.Artist
        ? (item as spotify.Artist).images
        : item is spotify.Playlist
            ? (item as spotify.Playlist).images
            : item is spotify.PlaylistSimple
                ? (item as spotify.PlaylistSimple).images
                : null;
    return images;
  }

  String durationFormatted(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

extension SpotifyStringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
