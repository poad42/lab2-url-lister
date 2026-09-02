# Lab 2 - UrlCount: Solution

## What this does

UrlCount counts how many times each URL appears in two Wikipedia articles. It is a modified WordCount1, written in Python with Hadoop Streaming (`URLMapper.py`, `URLReducer.py`), built from the provided sample (`Mapper.py`, `Reducer.py`).

## The regex

The mapper extracts URLs with the regex `href="([^"]*)"`.

## Where the count > 5 filter lives

The reducer sums the count for each URL and only outputs URLs with a count greater than 5.

## What counts as a URL

The extracted hrefs are mostly relative article links (`/wiki/...`), `#` fragments, `mw-data:TemplateStyles:...` style IDs, and absolute links such as `https://en.wikipedia.org/wiki/ISBN_(identifier)`.

## Software needed

| Component | Version | Notes |
|-----------|---------|-------|
| Hadoop | 3.3.6 | MapReduce / HDFS |
| Python | 3.x | for Hadoop Streaming |
| Docker + Docker Compose | current | runs the cluster |
| make | any | runs the Makefile targets |

The cluster is a Docker image on Ubuntu 26.04 (`Dockerfile`, `docker-compose.yml`, `conf/`, `entrypoint.sh`). It runs single-node (all daemons on localhost).

## How to build and run

Start the cluster:

```bash
docker compose up --build -d
```

Enter the container and use the Makefile:

```bash
docker exec -it hadoop-ubuntu bash
cd /lab

make prepare          # download the 2 Wikipedia articles into HDFS input
make filesystem       # (if needed) create /user/<whoami> in HDFS
make run              # run the original WordCount1            -> HDFS output
make stream           # run the Python streaming implementation -> HDFS stream-output
```

View results:

```bash
hdfs dfs -cat stream-output/part-00000
```

## Results

WordCount produced 576 unique words. UrlCount found 2,457 total URL references and, after the `> 5` filter, reported 10 unique URLs:

```
https://en.wikipedia.org/wiki/Google_File_System   6
https://en.wikipedia.org/wiki/MapReduce            6
mw-data:TemplateStyles:r1333133064                 7
mw-data:TemplateStyles:r886049734                 12
https://en.wikipedia.org/wiki/S2CID_(identifier)  14
#                                                 18
https://en.wikipedia.org/wiki/Doi_(identifier)    18
https://en.wikipedia.org/wiki/ISBN_(identifier)   18
mw-data:TemplateStyles:r1295599781                33
mw-data:TemplateStyles:r1333433106               121
```

The output differs from the README sample because the pages change each time they are downloaded.

### Execution timings (single-node Docker cluster, Hadoop 3.3.6)

| Program | Wall-clock time |
|---------|-----------------|
| UrlCount (Python) | ~20.0 s |

## 2-node vs 4-node dataproc comparison

The lab asks to run the same job on a dataproc cluster with 2 workers and with 4 workers, and compare the times. Both runs used Google Cloud dataproc (image `2.2.84-debian12`, Hadoop 3.3.6, region `europe-west1`).

**Caveat about the input.** To make the comparison fair, both clusters used the same input files (downloaded once, uploaded to a shared GCS bucket, copied into HDFS, verified identical via `md5sum`).

**Caveat about reducer outputs.** Dataproc ran more than one reducer (3 on the 2-worker cluster, 7 on the 4-worker cluster), so the output is split across several `part-r-*` files. The results below combine all part files.

| Cluster | Workers | UrlCount time | URLs with count > 5 |
|---------|---------|---------------|---------------------|
| `test-dataproc-2w` | 2 | 54.0 s | 10 |
| `test-dataproc-4w` | 4 | 57.9 s | 10 |

Both clusters produced the same 10 URLs, confirming the code works on a real cluster.

**Discussion.** The 4-worker cluster was slower (57.9 s) than the 2-worker cluster (54.0 s). This is expected for a tiny job: the input is two files (~800 KB), so more workers add overhead (more containers, more reducers) without speeding up the small map phase. For a much larger input, the 4-worker cluster would likely be faster.

## Resources and collaborators

* Author: Adhitya Mohan (CSCI 4253/5253)
* Collaborators: none
* Cloud resources used: Google Cloud dataproc (project `qwiklabs-gcp-02-9d2536ff4c3b`, region `europe-west1`, image `2.2.84-debian12`), two clusters (`test-dataproc-2w`, `test-dataproc-4w`), plus a GCS staging bucket.
* External resources used:
  * Apache Hadoop MapReduce tutorial (https://hadoop.apache.org/docs/r3.3.6/)
  * Hadoop Streaming (https://www.michael-noll.com/tutorials/writing-an-hadoop-mapreduce-program-in-python/)
  * bde2020 / Apache Hadoop Docker images for environment inspiration
