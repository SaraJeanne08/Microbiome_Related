#Filter OTU taxa tables and generate barplots with ggplot2
#Load packages
library(stringr)
library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)
library(digest)
library(RColorBrewer)
library(svglite)

###Work with all data in one set (mean ceiling grouped) - for consistent labeling/ colors per taxa. Use facet option to breakup per tissue type

## All_Spiders
X2019_Spider_Microbiome_ALL_MERGED_Mapping_FIle_noSgM_noMock_SPIDERSONLY_TAXA_L3_transposed <- read_csv("~/Desktop/QIIME2/2019_Spider_Microbiome_ALL_MERGED_Mapping_FIle_noSgM_noMock_SPIDERSONLY_TAXA_L3_transposed.csv")
ALL_Spider_Taxa <- X2019_Spider_Microbiome_ALL_MERGED_Mapping_FIle_noSgM_noMock_SPIDERSONLY_TAXA_L3_transposed
long_all <- ALL_Spider_Taxa %>% gather("Sample","nseq", 2:31)
View(long_all)                              

long_all_perc <- long_all %>% group_by(Sample) %>% mutate(sum_host = sum(nseq)) %>% mutate(perc_host = nseq/sum_host * 100)
long_all_perc$Taxonomy <- long_all_perc$index
View(long_all_perc)

long_all_perc_filtered2per <- long_all_perc %>% group_by(Taxonomy) %>% summarize(filter2per = max(perc_host)) %>% filter(filter2per<2) 
View(long_all_perc_filtered2per)
rare_2perc_all_taxa <- long_all_perc_filtered2per %>% .[["Taxonomy"]] %>% unique()

LAll_per2 <- long_all_perc %>% mutate(Taxa2 = ifelse(str_detect(Taxonomy, paste(rare_2perc_all_taxa, collapse="|")), TRUE, FALSE))
LAll_per2 %>% filter(Taxa2==TRUE)
long_all_perc %>% mutate(Taxa2 = ifelse(str_detect(Taxonomy, paste(rare_2perc_all_taxa, collapse="|")), "Other Rare Taxa", FALSE))
Long_all_Groupedfiltered <- long_all_perc %>% mutate(Taxa2 = ifelse(str_detect(Taxonomy, paste(rare_2perc_all_taxa, collapse="|")), "Other Rare Taxa", Taxonomy))
View(Long_all_Groupedfiltered)

#Make columns with species and tissue names in excel and clean up taxa names:
Long_all_Groupedfiltered$Relative_Abundance <- Long_all_Groupedfiltered$perc_host
Long_all_Groupedfiltered$Host_Species <- Long_all_Groupedfiltered$Sample
Long_all_Groupedfiltered$Taxa_Genera <- Long_all_Groupedfiltered$Taxa2

write.csv(Long_all_Groupedfiltered, file = "AllSpiders_Top2abovemembers.csv")

##Import csv file with cleanned up taxa names and any added columns for tissue type:
Long_all_Groupedfiltered_cleaned <- read_csv("AllSpiders_Top2abovemembers_clean.csv")
View(Long_all_Groupedfiltered_cleaned)


#Generate SVG of Ggplot2 with facet 2% not in all tissues:
svglite(file="20190427_AllSpiders_2per_cutoff_Taxa_no_legend_nolines.svg", width = 20, height = 16)
ggplot(Long_all_Groupedfiltered_cleaned, aes(x = Host_Species, y = Relative_Abundance, fill = Taxa_Genera)) + scale_color_manual(values=colors120) + geom_bar(aes(),stat = "identity", position = "stack") + theme(axis.title.x=element_text(face="bold",size=20),axis.title.y=element_text(face="bold",size=20,angle=90),axis.text.x=element_text(face="bold",size=16,angle = 90),axis.text.y=element_text(face="bold",size=16),plot.title=element_text(hjust=0.5,face="bold",size=24),strip.text=element_text(face="bold",size=16)) + theme(legend.position="none") + facet_grid(~Tissue, scales = "free", shrink = FALSE, drop = TRUE, space = "free_x") + ggtitle("Top Microbial Community Members in All Spiders (>2% Relative Abundance)")
dev.off()

svglite(file="20180704_AllSpiders_5per_cutoff_Taxa_no_legend_lines.svg", width = 20, height = 16)
ggplot(Long_all_5per_Groupedfiltered, aes(x = Host_Species, y = Relative_Abundance, fill = Taxa_Genera)) + scale_color_manual(values=colors120) + geom_bar(aes(),stat = "identity", position = "stack", color = "black") + theme(axis.title.x=element_text(face="bold",size=20),axis.title.y=element_text(face="bold",size=20,angle=90),axis.text.x=element_text(face="bold",size=16,angle = 90),axis.text.y=element_text(face="bold",size=16),plot.title=element_text(hjust=0.5,face="bold",size=24),strip.text=element_text(face="bold",size=16)) + theme(legend.position="none") + facet_grid(~Tissue, scales = "free", shrink = FALSE, drop = TRUE, space = "free_x") + ggtitle("Top Microbial Community Members in All Spiders (>5% Relative Abundance)")
dev.off()


#with_legend
#Taxa_Class <- Long_all_Groupedfiltered_cleaned$Taxa_Genera use for generating plots by taxonomic class instead of Genera
svglite(file="20190427_AllSpiders_2per_cutoff_Taxa_legend.svg", width = 20, height = 16)
ggplot(Long_all_Groupedfiltered_cleaned, aes(x = Host_Species, y = Relative_Abundance, fill = Taxa_Genera)) + geom_bar(aes(),stat = "identity", position = "stack") + theme(axis.title.x=element_text(face="bold",size=24),axis.title.y=element_text(face="bold",size=24,angle=90),axis.text.x=element_text(face="bold",size=20,angle=90),axis.text.y=element_text(face="bold",size=16),legend.position="bottom",legend.title=element_text(face="bold",size=16),legend.text=element_text(face="bold",size=11),legend.title.align=0,plot.title=element_text(hjust=0.5,face="bold",size=24),strip.text=element_text(face="bold",size=16)) + facet_grid(~Tissue, scales = "free", shrink = FALSE, drop = TRUE, space = "free_x") + ggtitle("Top Microbial Community Members in All Spiders (>2% Relative Abundance)")



