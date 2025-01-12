import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify/spotify.dart';
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

  /// Spotify service
  SpotifyService spotifyService = SpotifyService();

  @override
  void activate(Tide tide) {
    tide.useServices(services: [Tide.ids.service.keybindings]);

    // Spotify setup
    spotifyService.initialize();

    Tide.registerCommandContribution(
      TideTogglePanelVisibilityContribution(
        commandId: togglePanelVisibility,
        panelId: panelId,
      ),
    );

    final selectedItem = ValueNotifier<Object?>(null);

    tide.workbenchService.layoutService.addPanel(TidePanel(
      panelId: panelId,
      panelBuilder: (context, panel) {
        return TidePanelWidget(
          panelId: panel.panelId,
          backgroundColor: const Color(0xFFF3F3F3),
          position: TidePosition.left,
          resizeSide: TidePosition.right,
          minWidth: 100,
          maxWidth: 450,
          initialWidth: 220,
          child: TideSearchPanel(
            onChanged: (value) {
              spotifyService.search(value);
            },
            results: SpotifySearchResults(
              spotifyService: spotifyService,
              onSelected: (item) {
                selectedItem.value = item;
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
          position: TidePosition.center,
          child: ValueListenableBuilder<Object?>(
              valueListenable: selectedItem,
              builder: (context, state, child) {
                return SpotifyContentPanel(
                    spotifyService: spotifyService, item: selectedItem.value);
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

    // Add binding: shift-meta-F (shift-command-F) to toggle the search panel bar visibility.
    bindings.addBinding(
      TideKeybinding(
          keySet: LogicalKeySet(LogicalKeyboardKey.shift,
              LogicalKeyboardKey.meta, LogicalKeyboardKey.keyF),
          commandId: togglePanelVisibility),
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
                    item: item,
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

class SpotifyContentPanel extends StatelessWidget {
  const SpotifyContentPanel(
      {super.key, required this.spotifyService, this.item});

  final SpotifyService spotifyService;
  final Object? item;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Content Panel: ${item.toString()}'),
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

  final Object item;
  final bool hovering;
  final bool isItemSelected;

  /// Called when a pointer enters or exits the item.
  final ValueChanged<bool>? onHover;

  /// Called when the user taps this item.
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final title = item is Artist
        ? (item as Artist).name
        : item is Playlist
            ? (item as Playlist).name
            : item is PlaylistSimple
                ? (item as PlaylistSimple).name
                : item.toString();
    final subtitle = item is Artist
        ? (item as Artist).type.toString()
        : item is Playlist
            ? (item as Playlist).type.toString()
            : item is PlaylistSimple
                ? (item as PlaylistSimple).type.toString()
                : item.toString();
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
            Text(title ?? '',
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

  late SpotifyApi spotify;

  void initialize() {
    Tide.log('SpotifyService.initialize');

    const clientId = 'd7c4ce7c172041b8b63ef73e2afe9e3e';
    const clientSecret = 'bea841230da9405a8ad650cb1cc8bfc8';
    final credentials = SpotifyApiCredentials(clientId, clientSecret);
    spotify = SpotifyApi(credentials);
  }

  void updateState(SpotifyServiceState newState) {
    state.value = newState;
  }

  Future<void> search(String query) async {
    List<Object> searchResults = [];
    updateState(SpotifyServiceState(searchResults: searchResults));

    final search = await spotify.search
        .get(query, types: [SearchType.artist, SearchType.playlist]).first();

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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
