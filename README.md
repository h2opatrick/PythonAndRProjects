# PythonAndRProjects

## Introduction

Welcome to my project repository at Github! My name is **Zhanhao (Patrick)**, I am an early career professional with specialized expertise in data analytics and corporate finance (for now). I currently work as a financial data analyst in a traditional manufacturing business. I aspire to use data and objective approaches to transform them into actionable insights for my current company.

This repo is designed to illustrate my demonstrated project experience in building statistical models, machine learning algorithms, and doing data analysis in Python and R. I am currently seeking opportunities in data analytics and finance setting. Feel free to check out my LinkedIn website here --> [Click me!](https://www.linkedin.com/in/cch2owater)

<!-- projects -->
## Project

- Revenue Time Series Analysis (R)
  - The dataset contains 5 and a half years of data (from 2015 to 2020). 
  - I used the ARIMA approach to consider seasonality and randomness. The selected ARIMA model is then used to predict future revenue in the next 6 months.
 
- Inventory Sales Time Series Analysis (Python)
  - The dataset contains 2 and a half years of data (from 2018 to 2020). 
  - I tried using different approaches, including finding the optimal SARIMAX model, decision tree analysis, random forest, and linear regression and Ridge regression (after PCA with n_components of 4) to find the best model determined by the RMSE standard. 
  - Given the fact that the dataset contains many different inventories and the objective is to predict future quantity sold of a specific product, the model ends up being not much of use nor trustworthy. More data is needed to carry out a useful model for prediction purpose.
  
- Makeup product Categorization (Python)
  - model_df contains data from company internal database, data from Sephora and Lyst (over 10K rows of data). Data consists of its category type/use area (a total of 8, e.g. face, eye, body, etc.), product name, product description (text data).
  - I first used DNN to create a neural network for NLP. Afterwards, I also applied TFIDF neural network (term frequency document frequency). After building the neural network on training data, the network is then applied to testing data for accuracy testing. 
  - The TFIDF accuracy rate on testing data is higher than the DNN one. 

-  Shared Savings Program Visualization (Python)
