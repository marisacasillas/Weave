Weave together timestamped photos and audio into a video.

This is a very specific tool for a very specific situation conceived of by Marisa Casillas and largely implemented by Shawn Cameron Bird (2016). Here's, roughly, the data you need to make use of this:

- A directory of photos taken at regular intervals
  - Each named by the time at which it was taken
- An audio recording taken over roughly the same period that the photos span
- The local time at some offset into the audio recording
- The local time at which one of the photos was taken
  - The photo timestamps must be accurate relative to one another, but there's no assumption that their absolute times line up with the audio recording (e.g., the photo can be named 051523, but that doesn't mean it was taken at 5:15:03am.

Given all of that, this tool will create a video slideshow that aligns the photos to the audio, displaying "blank" frames where there are gaps in photos (audio but no photos for some time span) and playing silence where there are photos taken before the audio began or after it ended.

There is an example directory set up as described below that should work. Note that this has only really been tested with my setup (Narrative Cam 1 photos + .mp3 audio => an .mp4 video).

## Setup

This tool was written on macOS, but it should run fine on Linux. No promises for Windows. The main requirements:

- Python 2.7 or later (not 3.x)
- The `ffmpeg` executable

The recommended way to install `ffmpeg` on macOS is to install the [Homebrew package manager][1] and then run `brew install ffmpeg` from the command line. On Linux, you should be able to find and install `ffmpeg` using your system's standard package manager.

### The batch directory

When you actually run `weave`, you'll pass it the path to a batch directory containing all of the data that it requires. The batch directory can be located anywhere on the system, or even on external media, so long as it's readable and writable. Here's what the structure of the batch directory should look like:

```
BATCH_DIR
├── BLANK.jpg
├── recording1
│   ├── recording1.mp3
│   └── photos
│       ├── 040404.jpg
│       ├── …
│       └── 040534.jpg
├── recording2
│   ├── recording2.mp3
│   └── photos
│       ├── 053612.jpg
│       ├── …
│       └── 053850.jpg
├── recording3
│   ├── recording3.mp3
│   └── photos
│       ├── 040155.jpg
│       ├── …
│       └── 040603.jpg
└── ToWeave.csv
```

Let's start with `ToWeave.csv`, which must be present at the top level of the batch directory. I would not recommend making this in Excel, since Excel tries to auto-format the cells in an unhelpful way—a plain text editor should suffice. This should be a CSV that specifies the subdirectories for which to build videos and the requisite metadata for each video, with one row per video to be generated. The CSV must start with a header line. The column names and values are, in order:

- `Recname`: The name of the subdirectory containing the photo and audio data. Example value: `P1-7moF`. The name may be whatever you like.
- `AudioDuration`: The duration, in `HH:MM:SS` format, of the audio recording for this subdirectory.
- `AudioTimeStart`: The offset, in `HH:MM:SS` format, into the audio recording at which the local time at the time of recording is known (related to `AudioTimeCheck`).
- `AudioTimeCheck`: The local time, in `HH:MM:SS` format, at `AudioTimeStart`.
- `PhotoTimeStart`: The timestamp, in `HHMMSS` format, of the photo for which the local time at the time the photo was taken is known (this is like `AudioTimeStart`, but for the sequence of photos).
- `PhotoTimeCheck`: The local time, in `HH:MM:SS` format, at `PhotoTimeStart`.

The next file that must be present at the top level of the batch directory is `BLANK.jpg`. This is the image that will be used to fill blank frames; its dimensions should match the dimensions of the photos being used to generate the videos. The same image will be used for all videos.

Other than these two files, the only other requirement is one data directory per video to be generated. The name of these directories should match the `Recname` values in `ToWeave.csv`. Each directory should, itself, contain:

- An audio file named after the directory, but with the appropriate audio extension (e.g., `recording2.mp3` for data directory `recording2`)
- A directory named `photos` containing the photos, each named by its timestamp, in `HHMMSS` format, relative to the other photos (e.g., `040603.jpg`)

Once you have a batch directory set up as above, you're (finally) ready to try generating videos.

## Running

Download this project, open up a terminal, and change directories so that `weave` is in your current working directory. You can get some basic help by running:

```
./weave -h
```

You should see that you can change the expected file extension for the photos and audio file, as well as a few other defaults. You can also choose a maximum photo duration (by default, this is the picture frequency you chose for your camera; 15 seconds per photo? 30? The maximum will be the same across all the photos collected in your batch, so if you changed camera settings between recordings, run them in separate batches). Normally, a photo will display until the next photo's timestamp, but to handle missing photos, no photo will be displayed longer than the maximum duration (set to 15 seconds by default). Assuming you're fine with the defaults, however, you can start generating videos by running:

```
./weave /path/to/your/batch_directory
```

Note that the default output format is mpeg2, but mpeg4 is also possible (see -help).

Aligning the photos with the audio should happen pretty quickly (given the number of photos and length of the recording, of course), and most time will be spent running `ffmpeg` to generate a video from a sequence of second-long frames. You'll know when the video generation has started because `ffmpeg` will start printing out lots of diagnostic information; this is normal.

In the directory that comes with this set of scripts, you should have an example directory that is structured as required (`example-batch-dir`) and an example of what that directory should look like after running the `weave` script (`example-batch-dir-ALREADY_PROCESSED`).  Try making your own copy of `example-batch-dir` and running `weave` to start with before generating your own videos (just to check that things are working as expected):

```
./weave /path/to/your/example-batch-dir
```

[1]: https://brew.sh/