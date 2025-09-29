import 'package:dala_ishchisi/application/network_info/network_info_bloc.dart';
import 'package:dala_ishchisi/application/region/region_bloc.dart';
import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/common/extensions/region_extension.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/common/widgets/custom_appbar_back.dart';
import 'package:dala_ishchisi/domain/models/download_status_model.dart';
import 'package:dala_ishchisi/domain/models/region_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:heroicons/heroicons.dart';

class RegionView extends StatefulWidget {
  const RegionView({super.key});

  @override
  State<RegionView> createState() => _RegionViewState();
}

class _RegionViewState extends State<RegionView> {
  @override
  void initState() {
    context.read<RegionBloc>().add(const RegionEvent.fetchRegions());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RegionBloc, RegionState>(
          listener: (context, state) {
            state.maybeMap(
              regions: (_) => EasyLoading.dismiss(),
              failed: (_) => EasyLoading.dismiss(),
              orElse: () => EasyLoading.show(),
            );
          },
        ),
        BlocListener<NetworkInfoBloc, NetworkInfoState>(
          listener: (context, state) {
            if (state.isConnected) {
              context.read<RegionBloc>().add(const RegionEvent.fetchRegions());
            }
          },
        ),
      ],
      child: BlocBuilder<RegionBloc, RegionState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(Words.offlineMaps.str),
              leadingWidth: 100,
              leading: const CustomAppbarBack(),
            ),
            body: state.mapOrNull(
              regions: (value) => _RegionListView(
                regions: value.regions,
                progress: value.progress,
                cachedRegions: value.cachedRegions,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final bool isLoading;
  final bool isCached;
  final double? progress;

  const _Button({
    this.isLoading = false,
    this.isCached = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 24,
      child: Builder(
        builder: (context) {
          if (isLoading) {
            return Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.blue.shade5,
                  value: progress != null ? (progress! / 100) : null,
                ),
                const Align(
                  alignment: Alignment.center,
                  child: HeroIcon(
                    HeroIcons.xMark,
                    size: 20,
                  ),
                ),
              ],
            );
          }
          if (isCached) {
            return HeroIcon(
              HeroIcons.trash,
              color: AppColors.red.shade6,
            );
          }
          return HeroIcon(
            HeroIcons.arrowDown,
            color: AppColors.gray.shade5,
            style: HeroIconStyle.mini,
          );
        },
      ),
    );
  }
}

class _RegionListView extends StatelessWidget {
  final List<RegionModel> regions;
  final List<DownloadStatusModel> progress;
  final Map<String, String> cachedRegions;

  const _RegionListView({
    required this.regions,
    required this.progress,
    required this.cachedRegions,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: ShapeDecoration(
          color: Theme.of(context).cardColor,
          shape: Theme.of(context).cardTheme.shape!,
        ),
        child: ListView.separated(
          itemCount: regions.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          separatorBuilder: (context, _) => const Divider(),
          itemBuilder: (context, index) {
            final regionId = regions[index].regionId;
            final currentProgress =
                progress.where((e) => e.filename == regionId).singleOrNull;
            bool isLoading =
                currentProgress?.status == DownloadStatus.enqueued ||
                    currentProgress?.status == DownloadStatus.running;

            final isCached = cachedRegions[regionId] != null;
            return Padding(
              key: ValueKey(regionId),
              padding: const EdgeInsets.all(12),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Text(regions[index].getName(AppGlobals.lang)),
                  ),
                  Text("${regions[index].fileSizeInMegabytes} MB"),
                  IconButton(
                    onPressed: () {
                      final bloc = context.read<RegionBloc>();
                      if (isLoading) {
                        return bloc.add(
                          RegionEvent.cancelDownload(
                            regionId: regionId,
                          ),
                        );
                      }
                      if (isCached) {
                        return bloc.add(
                          RegionEvent.delete(regionId: regionId),
                        );
                      }
                      return bloc.add(
                        RegionEvent.download(regionId: regionId),
                      );
                    },
                    icon: _Button(
                      isLoading: isLoading,
                      progress:
                          currentProgress?.status == DownloadStatus.enqueued
                              ? null
                              : currentProgress?.progress,
                      isCached: isCached,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
