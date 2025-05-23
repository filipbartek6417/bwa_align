version 1.0

task align_with_bwa {
  input {
    File reference
    File fasta1
    File fasta2
  }

  command <<<
    set -e
    apt-get update && apt-get install -y apt-utils curl bwa
    bwa index ~{reference}
    bwa mem -5SP -T0 -t16 ~{reference} ~{fasta1} ~{fasta2} > aligned.sam
  >>>

  output {
    File sam_file = "aligned.sam"
  }

  runtime {
    docker: "ubuntu:20.04"
    disks: "local-disk 5000 SSD"
    memory: "100G"
    cpu: 32
  }
}

workflow bwa_alignment {
  input {
    File reference = "gs://fc-c3eed389-0be2-4bbc-8c32-1a40b8696969/bartek_testing/hs1_ref/hs1.fa"
    File fasta1 = "gs://fc-c3eed389-0be2-4bbc-8c32-1a40b8696969/uploads/assemblies/PAN027.verkko2.1.Q28_k50000.haplotype1.20250425.fasta"
    File fasta2 = "gs://fc-c3eed389-0be2-4bbc-8c32-1a40b8696969/uploads/assemblies/PAN027.verkko2.1.Q28_k50000.haplotype2.20250425.fasta"
  }

  call align_with_bwa {
    input:
      reference = reference,
      fasta1 = fasta1,
      fasta2 = fasta2
  }

  output {
    File aligned_sam = align_with_bwa.sam_file
  }
}
