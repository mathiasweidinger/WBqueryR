
library(hexSticker)
library(tidyverse)
library(magick)
library(sysfonts)

fonts <- font_files()


font_add("broadway", "BROADW.TTF")

sticker(
    subplot = "look_it_up.PNG",
    package = "WBqueryR",
    s_width = 0.5,
    s_height = 0.5,
    s_x = 1,
    s_y = 1.25,
    p_size = 15,
    h_fill = "white",
    h_color = "black",
    h_size = 1.5,
    url = "v 0.0.0.9000",
    u_size = 5,
    u_color = "hotpink",
    spotlight = T,
    # l_y = 1.5,
    # l_x = 1.3,
    # l_height = 3,
    # l_width = 3,
    # l_alpha = 0.5,
    p_color = "black",
    p_family = "broadway",
    p_x = 1,
    p_y = 0.75
) %>% print()

