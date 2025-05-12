version 1.0

task align_with_bwa {
  input {
    String fastq_url
    String reference_path
  }

  command {
    set -e

    # Install required tools
    apt-get update && apt-get install -y apt-utils curl bwa

    # Stream the FASTQ file and align with bwa mem
    curl -s ~{fastq_url} | \
    bwa mem -5SP -T0 -t16 ~{reference_path} - > aligned.sam
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
    String fastq_url = "https://s3-us-west-2.amazonaws.com/human-pangenomics/submissions/5b73fa0e-658a-4248-b2b8-cd16155bc157--UCSC_GIAB_R1041_nanopore/HG002_R1041_PoreC/Dorado_v4/HG002_1_Dorado_v4_R1041_PoreC_400bps_sup.fastq.gz"
    String reference_path = "gs://fc-c3eed389-0be2-4bbc-8c32-1a40b8696969/bartek_testing/hs1_ref/hs1.fa"  # Update with the Terra directory path
  }

  call align_with_bwa {
    input:
      fastq_url = fastq_url,
      reference_path = reference_path
  }

  output {
    File aligned_sam = align_with_bwa.sam_file
  }
}
