version 1.0

task align_with_bwa {
  input {
    String fastq_path
    String reference_path
  }

  command {
    set -e

    # Install required tools
    apt-get update && apt-get install -y apt-utils curl bwa
    ls -l "gs://fc-c3eed389-0be2-4bbc-8c32-1a40b8696969/bartek_testing/hs1_ref"
    # Align with bwa mem
    bwa mem -5SP -T0 -t16 ~{reference_path} ~{fastq_path} -o aligned.sam
  }

  output {
    File sam_file = "aligned.sam"
  }

  runtime {
    docker: "ubuntu:20.04"
    disks: "local-disk 150 SSD"
    memory: "64G"
    cpu: 16
  }
}

workflow bwa_alignment {
  input {
    String fastq_path = "gs://fc-c3eed389-0be2-4bbc-8c32-1a40b8696969/submissions/08166185-8d5e-4374-9bb8-cdfb15370970/sample_fastq/547fd72c-d644-445e-a072-06c4ae8d5aa8/call-stream_and_sample/subsampled.fastq.gz"
    String reference_path = "gs://fc-c3eed389-0be2-4bbc-8c32-1a40b8696969/bartek_testing/hs1_ref/hs1.fa"  # Update with the Terra directory path
  }

  call align_with_bwa {
    input:
      fastq_path = fastq_path,
      reference_path = reference_path
  }

  output {
    File aligned_sam = align_with_bwa.sam_file
  }
}
