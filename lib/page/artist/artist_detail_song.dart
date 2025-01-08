import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mix_music/api/api_factory.dart';
import 'package:mix_music/entity/mix_artist.dart';
import 'package:mix_music/entity/mix_song.dart';
import 'package:mix_music/entity/page_entity.dart';
import 'package:mix_music/route/routes.dart';
import 'package:mix_music/utils/SubordinateScrollController.dart';
import 'package:mix_music/widgets/app_image.dart';
import 'package:mix_music/widgets/message.dart';

import '../../player/music_controller.dart';
import '../../widgets/hyper/hyper_loading.dart';
import '../../widgets/page_list_view.dart';

class ArtistDetailSong extends StatefulWidget {
  const ArtistDetailSong({super.key, required this.artist});

  final MixArtist artist;

  @override
  State<ArtistDetailSong> createState() => _ArtistDetailSongState();
}

class _ArtistDetailSongState extends State<ArtistDetailSong> with AutomaticKeepAliveClientMixin {
  late EasyRefreshController refreshController;
  MusicController music = Get.put(MusicController());
  Rxn<PageEntity> pageEntity = Rxn();
  RxList<MixSong> songList = RxList();
  RxBool firstLoad = RxBool(true);

  @override
  void initState() {
    super.initState();
    refreshController = EasyRefreshController(controlFinishLoad: true, controlFinishRefresh: true);

    Future.delayed(const Duration(milliseconds: 300)).then((v) {
      artistSong(artist: widget.artist);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: firstLoad.value
            ? const HyperLoading()
            : PageListView(
                controller: refreshController,
                onRefresh: () {
                  return artistSong(artist: widget.artist);
                },
                onLoad: () {
                  return artistSong(artist: widget.artist, page: pageEntity.value?.page ?? 0);
                },
                scrollController: SubordinateScrollController(context.findAncestorStateOfType<ExtendedNestedScrollViewState>()!.innerController),
                itemCount: songList.length,
                itemBuilder: (BuildContext context, int index) {
                  var song = songList[index];
                  return Obx(() => ListTile(
                        selected: music.currentMusic.value?.id == song.id,
                        leading: AppImage(url: song.pic ?? ""),
                        title: Row(
                          children: [
                            Flexible(child: Text(song.title ?? "", maxLines: 1, overflow: TextOverflow.ellipsis)),
                            song.vip == 1
                                ? Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                                      border: Border.all(width: 1, color: Colors.green),
                                    ),
                                    child: const Text("VIP", maxLines: 1, style: TextStyle(fontSize: 10, color: Colors.green)),
                                  )
                                : Container(),
                          ],
                        ),
                        subtitle: Text(song.subTitle ?? "", overflow: TextOverflow.ellipsis, maxLines: 1),
                        trailing: song.mv != null
                            ? IconButton(
                                onPressed: () {
                                  Get.toNamed(Routes.mvDetail, arguments: song.mv);
                                },
                                icon: Icon(Icons.music_video))
                            : null,
                        onTap: () {
                          music.playList(list: songList, index: index);
                        },
                      ));
                },
              ),
      ),
    );
  }

  ///获取歌单
  void artistSong({required MixArtist artist, int page = 0}) {
    ApiFactory.api(package: widget.artist.package)?.artistSong(artist: artist, page: page, size: 20).then((value) {
      firstLoad.value = false;
      pageEntity.value = value.page;
      if (page == 0) {
        songList.clear();
        refreshController.finishRefresh();
      }
      refreshController.finishLoad(pageEntity.value?.last == false ? IndicatorResult.success : IndicatorResult.noMore, true);

      songList.addAll(value.data ?? []);

      // showComplete("操作成功");
    }).catchError((e) {
      firstLoad.value = false;
      if (page == 0) {
        refreshController.finishRefresh(IndicatorResult.fail, true);
      } else {
        refreshController.finishLoad(IndicatorResult.fail, true);
      }
      showError(e);
    });
  }

  @override
  bool get wantKeepAlive => true;
}
