## Research Objectives  
1. Analyze consumer survey data to identify key factors influencing preferences for mountain wines.  
2. Use factor analysis (Principal Components Factor Analysis) to reduce data dimensionality.  
3. Apply clustering methods (Ward’s Method and K-means) to segment consumers into distinct groups.  
4. Develop targeted marketing strategies based on consumer segment characteristics.  


## Methodology  
### 1. Data Collection  
- Survey of 260 consumers on sociodemographics, behaviors, and attitudes toward mountain wines.  
- 15 variables measuring product preferences and environmental views.  

### 2. Analytical Techniques  
#### Factor Analysis  
- **Principal Components Factor Analysis (PCFA)**: Transforms variables into uncorrelated components to capture variance.  
- Identified 2 main factors:  
  - Factor 1: Familiarity with mountain wine attributes (e.g., rarity, regionality)  
  - Factor 2: Environmental consciousness  

#### Clustering  
- **Ward’s Method**: Hierarchical clustering to minimize within-cluster variance.  
- **K-means Clustering**: Refines clusters using initial centroids from Ward’s method.  
- Elbow method determined 3 optimal clusters.  

<div align=center>
<img src="https://github.com/Seailvia/CFCA-Consumer-Preferences-Based-Factor-and-Cluster-Analysis/blob/main/scree.png" width = 800>
</div>

## Key Findings  
### Consumer Segments  
1. **Cluster 1: Environmentally Responsible Consumers**  
   - High environmental awareness, moderate interest in product attributes.  
   - Older demographic, higher willingness to pay (mean bid: 2.87).  

2. **Cluster 2: Product-Attribute Focused Consumers**  
   - Strong appreciation for mountain wine characteristics, lower environmental concern.  
   - Younger demographic, lower payment willingness (mean bid: 1.92).  

3. **Cluster 3: Low Interest Consumers**  
   - Low engagement with both product attributes and environmental issues.  
   - Lowest payment willingness (mean bid: 1.25).

<div align=center>
<img src="https://github.com/Seailvia/CFCA-Consumer-Preferences-Based-Factor-and-Cluster-Analysis/blob/main/cluster.png" width = 800>
</div>

### Key Insights  
- Environmental responsibility and age correlate with higher purchase intent.  
- Target marketing should prioritize Cluster 1 as primary consumers and engage Cluster 2 through environmental education.  

### Stucture of R Files
Data Storage: Consumer preference data for mountain wines is stored in ```wineDATA```, encompassing 260 survey responses with 15 variables on sociodemographics, behaviors, and attitudes toward mountain wines and environmental protection. Key demographic insights include 46% male/54% female respondents and 61% high school/39% university education levels.

Clustering & Factor Analysis Code in ```FA-CA-R.R```:
Factor Analysis: Implements Principal Components Factor Analysis (PCFA) to reduce data dimensionality. Using eigenvalue decomposition of the covariance matrix, the scree plot identifies 2 key factors: Factor 1 (RC1) captures familiarity with mountain wine attributes (variables X1-X9, loadings ~0.90), and Factor 2 (RC2) reflects environmental consciousness (variables X10-X15, loadings ~0.93).
Clustering: Employs Ward’s Method (hierarchical clustering) with squared Euclidean distance, minimizing within-cluster variance (ESS). The elbow method confirms 3 optimal clusters, later refined by K-means clustering using Ward’s centroids as initial seeds.

Visualization in ```visualization.R```:
Scree Plot: Visualizes eigenvalues to determine factor dimensionality, showing an elbow at 2 components.
Cluster Profile Plots: Displays mean factor scores for 3 clusters: Environmentally Responsible Consumers (high RC2, moderate RC1), Product-Attribute Focused Consumers (high RC1, low RC2), and Low Interest Consumers (low RC1/RC2).
Demographic Plots: Shows gender/education/age distributions and bid/y-value means across clusters, highlighting Cluster 1’s higher payment intent (mean bid=2.87) and age.

