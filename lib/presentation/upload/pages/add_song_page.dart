import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app_clone/common/widgets/appbar/app_bar.dart';
import 'package:spotify_app_clone/data/models/song/upload_song_req.dart';
import 'package:spotify_app_clone/presentation/upload/bloc/upload_song_cubit.dart';
import 'package:spotify_app_clone/presentation/upload/bloc/upload_song_state.dart';

import '../../../core/configs/theme/app_colors.dart';

class AddSongPage extends StatefulWidget {
  const AddSongPage({super.key});

  @override
  State<AddSongPage> createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {
  final _title = TextEditingController();
  final _artist = TextEditingController();
  String? _audioPath;
  String? _coverPath;
  bool _isPublic = true;
  final num _durationSeconds = 0;

  Future<void> _pickAudio() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav', 'acc', 'flac'],
    );
    if (picked != null && picked.files.single.path != null) {
      _audioPath = picked.files.single.path!;
      setState(() {});
    }
  }

  Future<void> _pickCover() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    if (picked != null && picked.files.single.path != null) {
      _coverPath = picked.files.single.path!;
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (_audioPath == null || _title.text.isEmpty || _artist.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select audio and fill title/artist.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    final req = UploadSongReq(
      localAudioPath: _audioPath!,
      title: _title.text.trim(),
      artist: _artist.text.trim(),
      durationSeconds: _durationSeconds / 60,
      releaseDate: DateTime.now(),
      localCoverPath: _coverPath,
      isPublic: _isPublic,
    );
    context.read<UploadSongCubit>().upload(req);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UploadSongCubit(),
      child: BlocConsumer<UploadSongCubit, UploadSongState>(
        listener: (context, state) {
          if (state is UploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Song Uploaded Successfully!",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is UploadFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "An error occurred, Please try again later.",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        },
        builder: (context, state) {
          final loading = state is UploadUploading;
          return Scaffold(
            appBar: BasicAppBar(
              title: Text(
                "Add Song",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  TextField(
                    controller: _title,
                    decoration: const InputDecoration(
                      labelText: "Enter Title As song",
                    ).applyDefaults(Theme.of(context).inputDecorationTheme),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _artist,
                    decoration: const InputDecoration(
                      labelText: "Enter Artist As song",
                    ).applyDefaults(Theme.of(context).inputDecorationTheme),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: loading ? null : _pickAudio,
                        child: Text(
                          _audioPath == null ? 'Pick Audio' : 'Change Audio',
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_audioPath != null)
                        Expanded(
                          child: Text(
                            File(_audioPath!).path.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      OutlinedButton(
                        onPressed: loading ? null : _pickCover,
                        child: Text(
                          _coverPath == null ? 'Pick Cover' : 'Change Cover',
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_coverPath != null)
                        Text(
                          File(_coverPath!).path.split('/').last,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _isPublic,
                    onChanged: loading
                        ? null
                        : (v) => setState(() => _isPublic = v),
                    title: const Text("Make Public"),
                    subtitle: const Text('If off, only you can see this song'),
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const CircularProgressIndicator(
                              color: AppColors.primary,
                            )
                          : const Text(
                              'Upload',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
