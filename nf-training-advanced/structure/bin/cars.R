#!/usr/bin/env Rscript
library(tidyverse)

plot <- ggplot(mpg, aes(displ, hwy, colour = class)) + geom_point()
mtcars |> write_tsv("cars.tsv")
ggsave("cars.png", plot = plot)





# mkdir -p bin
# cat << EOF > bin/cars.R  # Everything between EOF and the terminating EOF will be written into the cars.R file
# #!/usr/bin/env Rscript
# library(tidyverse)

# plot <- ggplot(mpg, aes(displ, hwy, colour = class)) + geom_point()
# mtcars |> write_tsv("cars.tsv")
# ggsave("cars.png", plot = plot)
# EOF  # End Of File
# chmod +x bin/cars.R
