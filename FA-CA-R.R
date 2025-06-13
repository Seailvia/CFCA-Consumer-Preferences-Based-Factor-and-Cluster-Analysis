library(dplyr)
library(psych)
library(GPArotation)
library(reshape2)
library(ggplot2)
library(GGally)
library(fmsb)  # for radar chart

# Load data
load("wine.RDATA")

# Descriptive statistics
wine$gender <- as.factor(wine$gender)
wine$edu <- as.factor(wine$edu)

# Descriptive statistics for numeric variables
numeric_summary <- wine %>%
  select(X1:X15, age, bid, y) %>%
  summarise_all(list(mean = mean, sd = sd, median = median, min = min, max = max))

print(numeric_summary)

# Descriptive statistics for categorical variables
categorical_summary <- wine %>%
  group_by(gender, edu) %>%
  summarise(count = n()) %>%
  ungroup()

print(categorical_summary)

# Plotting
# Histogram of a numeric variable (e.g., bid)
ggplot(wine, aes(x = y)) +
  geom_histogram(binwidth = 0.5, fill = "lightgreen", color = "black") +
  theme_minimal() +
  labs(title = "Histogram of y", x = "y", y = "Frequency")

# Boxplot of y by gender
ggplot(wine, aes(x = gender, y = y, fill = gender)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Boxplot of y by gender", x = "gender", y = "y")

# Decide the number of factors
fit <- principal(r = wine[, 1:15], nfactors = 15, rotate = "none")
fit

# Number of factors using latent root criterion
eigenvalues <- fit$values
num_factors_latent_root <- sum(eigenvalues > 1)
num_factors_latent_root

# 2-factor model
fitb <- principal(r = wine[, 1:15], nfactors = 2, rotate = "varimax")
fitb

# Ward's method
dist_matrix <- dist(fitb$scores)
ward_clustering <- hclust(dist_matrix, method = "ward.D2")

# stage plot
exp<-scale(wine[,1:15])
dist<-dist(exp,method="euclidean")^2
fit <- hclust(dist, method="ward.D")
history<-cbind(fit$merge,fit$height)
history

ggplot(mapping=aes(x=1:length(fit$height),y=fit$height))+
  geom_line()+
  geom_point()+
  labs(x="stage",y="height")

# Plot the dendrogram with distances
plot(ward_clustering, main = "Dendrogram", xlab = "", sub = "", cex = 0.8)

# Elbow method to determine optimal clusters
wss <- sapply(1:10, function(k) {
  kmeans(fitb$scores, centers = k, nstart = 10)$tot.withinss
})

# Plot the elbow method results
plot(1:10, wss, type = "b", pch = 19, xlab = "Number of Clusters", ylab = "Total Within-Cluster Sum of Squares",
     main = "Elbow Method for Optimal Clusters")

# Determine number of clusters
num_clusters <- 3
clusters <- cutree(ward_clustering, k = num_clusters)

# K-means method
kmeans_means <- aggregate(fitb$scores, by = list(cluster = clusters), FUN = mean)
initial_centers <- kmeans_means[, -1]
kmeans_result <- kmeans(fitb$scores, centers = initial_centers, nstart = 1)

# Final clustering result plot
kmeans_means_melted <- melt(kmeans_means, id.vars = "cluster")
ggplot(kmeans_means_melted, aes(x = variable, y = value, group = cluster, color = as.factor(cluster))) +
  geom_line() +
  geom_point(size = 3) +
  labs(title = "Profile Plot of K-means Cluster Means", x = "Variables", y = "Standardized Values") +
  theme_minimal() +
  scale_color_discrete(name = "Cluster")

# Summary statistics by cluster
background_vars <- wine[, 16:20]
results <- data.frame(Cluster = as.factor(kmeans_result$cluster), background_vars)

summary_stats <- results %>%
  group_by(Cluster) %>%
  summarise(
    male_ratio = mean(gender == "male"),
    female_ratio = mean(gender == "female"),
    university_ratio = mean(edu == "university"),
    highschool_ratio = mean(edu == "highschool"),
    mean_age = mean(age, na.rm = TRUE),
    mean_bid = mean(bid, na.rm = TRUE),
    mean_y = mean(y, na.rm = TRUE)
  )

print(summary_stats)

# Gender ratio bar chart by cluster
ggplot(summary_stats, aes(x = Cluster)) +
  geom_bar(aes(y = male_ratio, fill = "Male"), stat = "identity", position = "dodge") +
  geom_bar(aes(y = female_ratio, fill = "Female"), stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Male" = "skyblue", "Female" = "pink")) +
  theme_minimal() +
  labs(title = "Gender Ratio by Cluster", y = "Ratio", x = "Cluster") +
  scale_y_continuous(labels = scales::percent)

# Education level ratio bar chart by cluster
ggplot(summary_stats, aes(x = Cluster)) +
  geom_bar(aes(y = university_ratio, fill = "University"), stat = "identity", position = "dodge") +
  geom_bar(aes(y = highschool_ratio, fill = "Highschool"), stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("University" = "lightgreen", "Highschool" = "lightcoral")) +
  theme_minimal() +
  labs(title = "Education Level Ratio by Cluster", y = "Ratio", x = "Cluster") +
  scale_y_continuous(labels = scales::percent)

# Box plot of mean age, bid, and y by cluster
melted_stats <- melt(summary_stats, id.vars = "Cluster")
ggplot(melted_stats, aes(x = as.factor(Cluster), y = value, fill = as.factor(Cluster))) +
  geom_boxplot() +
  facet_wrap(~variable, scales = "free") +
  theme_minimal() +
  labs(title = "Mean Age, Bid, and Y by Cluster", x = "Cluster", y = "Value") +
  scale_fill_brewer(palette = "Pastel1")

# Scatterplot matrix of age, bid, and y by cluster
results$Cluster <- as.factor(results$Cluster)
ggpairs(results[, c("age", "bid", "y", "Cluster")], 
        columns = 1:3, 
        ggplot2::aes(color = Cluster, alpha = 0.6)) +
  theme_minimal() +
  labs(title = "Scatterplot Matrix of Age, Bid, and Y by Cluster")

# Prepare data for radar chart
radar_data <- summary_stats %>%
  select(Cluster, mean_age, mean_bid, mean_y)

row.names(radar_data) <- radar_data$Cluster
radar_data <- radar_data[, -1] # Remove Cluster column
radar_data <- rbind(apply(radar_data, 2, max), apply(radar_data, 2, min), radar_data)

# Radar chart
radarchart(radar_data, axistype = 1, 
           pcol = c("blue", "red", "green"), pfcol = c("skyblue", "lightpink", "lightgreen"),
           plwd = 2, plty = 1, 
           cglcol = "grey", cglty = 1, axislabcol = "grey", caxislabels = seq(0, max(radar_data), 1),
           title = "Radar Chart of Mean Age, Bid, and Y by Cluster")

print(summary_stats)
# chisq_test_gender <- chisq.test(table(results$Cluster, results$gender))
# chisq_test_age <- chisq.test(table(results$Cluster, results$age))
# chisq_test_edu <- chisq.test(table(results$Cluster, results$edu))
# print(chisq_test_gender)
# print(chisq_test_age)
# print(chisq_test_edu)

