library(ggplot2)
library(forcats)

test3 <- readRDS("/home/jose/Documents/Science/Dissertation/Analysis/misc/milstead_x_lagos.rds")

test3$lakeconnectivity <- 
  fct_recode(test3$lakeconnectivity, 
             "Lakestream" = "Secondary",
             "Stream" = "Primary",
             "Headwater" = "Headwater")

test3$lakeconnectivity <- factor(test3$lakeconnectivity, 
                  levels = c("Isolated", "Headwater", "Stream", "Lakestream"))

test3 <- test3[test3$hrt > 0,] 
test3 <- test3[test3$AreaSqKm > 0.04,] # rm less than 4 ha
test3 <- test3[!is.na(test3$lakeconnectivity),]

yr_labels <- c("1e-07", "1e-05", 
               as.character(10/365), 
               as.character(2/12), as.character(6/12), 
               "2", "10")

format_labels <- function(x, mult_factor){
  gsub("\\.+$", "\\1", gsub("0+$", "\\1",
    trimws(format(round(as.numeric(x), 6) * 
      mult_factor, scientific = FALSE)), perl = TRUE))
  }

day_labels   <- ceiling(as.numeric(
  format_labels(yr_labels, 365)) / 10) * 10
minute_labels  <- ceiling(as.numeric(
  format_labels(yr_labels, 365 * 24 * 60)) / 10) * 10
month_labels  <- round(as.numeric(
  format_labels(yr_labels, 12)), 0)

mixed_labels <- paste0(
      c(minute_labels[1:2], day_labels[3], month_labels[4:5], yr_labels[6:7]), 
      c(" min", " min", " days", " ", " mon.", " years", " years"))

quants <- exp(quantile(log(test3[!is.na(test3$lakeconnectivity), "hrt"])))

# gg_fit_single <- ggplot(data = test3, 
#     aes(x = hrt, y = Rp)) + geom_point(size = 0.9) +
#   scale_x_log10(labels = mixed_labels, 
#     breaks = as.numeric(yr_labels), limits = c(1 / 365, 11)) +
#   stat_smooth(method = "glm", method.args = list(family = "binomial"), 
#               se = TRUE) +
#   scale_color_brewer(palette = "Set1") +
#   cowplot::theme_cowplot() + 
#   theme(legend.position = "none", legend.title = element_blank(), legend.text = element_text()) +
#   xlab("Residence Time") +
#   ylab("P Retention (%)") + 
#   geom_segment(data = data.frame(x = quants[c(2, 4)], y = c(0.8, 0.8)), 
#                aes(x = x, y = c(0, 0), xend = x, yend = y), 
#                color = "gray42", size = 1.5, linetype = 2)
# 
# if(!interactive()){
#   ggsave("milstead_single.pdf", gg_fit_single, height = 5)
# }

test4 <- droplevels(test3[test3$lakeconnectivity != "Isolated",])

(gg_fit_multi <- ggplot(data = test4, aes(x = hrt, y = Rp)) +
  geom_point(size = 0.9) +
  scale_x_log10(labels = mixed_labels, 
                breaks = as.numeric(yr_labels), limits = c(1 / 365, 11)) +
  stat_smooth(method = "glm", method.args = list(family = "binomial"), 
              se = TRUE, aes(color = lakeconnectivity), 
              data = test4) +
  scale_color_brewer(palette = "Set1") +
  cowplot::theme_cowplot() + 
  theme(legend.title = element_blank(), legend.position = c(0.18, 0.8),
        legend.text = element_text(), plot.caption = element_text(size = 10, hjust = 0)) +
  xlab("Residence Time") +
  ylab("P Retention (%)")) 
  # geom_segment(data = data.frame(x = quants[c(2, 4)], y = c(0.8, 0.8)), 
  #              aes(x = x, y = c(0, 0), xend = x, yend = y), 
  #              color = "gray42", size = 1.5, linetype = 2)) 
  # labs(caption = "Re-analysis of data from [3] with data from [4]"))  
  # ggtitle("Lake P Retention as a function of \n residence time and lake connectivity"))

ggsave("figures/milstead_multi.pdf", gg_fit_multi, height = 3)