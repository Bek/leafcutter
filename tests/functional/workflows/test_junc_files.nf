params.bamsIdentifierGroupA = "CEU"
params.bamsIdentifierGroupB = "YRI"
params.bamsDir = "gs://leafcutter-inputs/bams"

process makeJuncFiles {
  
  publishDir 'test-outputs'
  cpus 2
  container 'oceansource/leafcutter:workflows'
  containerOptions = "--user root"
  input:
    path bamFile

  output:
    path "${bamFile}.junc"

  """
  touch ${bamFile}.bed
  touch ${bamFile}.junc
  samtools view $bamFile | filter_cs.py | sam2bed.pl --use-RNA-strand - ${bamFile}.bed
  bed2junc.pl ${bamFile}.bed ${bamFile}.junc  
  """
}

workflow {
  groupA = Channel.fromPath("${params.bamsDir}/*${params.bamsIdentifierGroupA}*.bam")
  groupB = Channel.fromPath("${params.bamsDir}/*${params.bamsIdentifierGroupB}*.bam")
  allBams = groupA.concat(groupB)
  result = makeJuncFiles(allBams).collect()
  result.view()
}