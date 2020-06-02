# Custom version of binscatter.R,
# Source version can be found here: https://github.com/apoorvalal/LalRUtils/blob/master/R/binscatter.R

binscatter = function(fmla, key_var, data, plotraw = TRUE, bins = 20,
                      rawdata_colour = 'black', rawdata_alpha = 0.2, rawdata_size = 0.5,
                      linfit_width = 0.6, linfit_colour = 'blue',
                      cef_point_size = 2, cef_point_colour = 'black',
                      ci_colour = 'gray', ci_alpha = 0.3, xlabname="", ylabname="", titletext="", ylimit=c(-1,1), xlimit=c(-10,20)){
    # load libraries
    require(lfe); require(stringr); require(ggplot2)
    # FWL
    y <- unlist(strsplit(fmla, "~"))[1] ; x <- unlist(strsplit(fmla, "~"))[2]
    controls <- str_replace(x, key_var, '1') # replace main X with intercept
    # residualise regressions
    reg_y <- felm(formula(paste0(y, "~", controls)), data = data)
    reg_x <- felm(formula(paste0(key_var, "~", controls)), data = data)
    resid_y <- resid(reg_y); resid_x <- resid(reg_x)
    df <- data.frame(resid_y, resid_x)
    colnames(df) <- c(paste0("residual_", names(df)[1]), paste0("residual_", names(df)[2]))
    # are errors clustered
    cluster_grp <- trimws(unlist(strsplit(fmla, "\\|"))[4])
    # regression with partialed Xs and Ys
    if (is.na(cluster_grp)) { reg <- felm(resid_y ~ resid_x) }
    else{reg <- felm(formula(paste0("resid_y ~ resid_x | 0 | 0 |", cluster_grp)), data)}
    intercept <- coef(reg)[1] ; slope <- coef(reg)[2]
    # variance covariance matrix
    if (is.null(reg$clustervcv)) { vcov <- reg$robustvcv; se_type <- "robust" }
    else { vcov <- reg$clustervcv; se_type <- paste0("clustered by ", cluster_grp) }
    Terms <- terms(reg); m_mat <- model.matrix(Terms, data = df)
    fit <- as.vector(m_mat %*% coef(reg))
    se_fit <- sqrt(rowSums((m_mat %*% vcov) * m_mat))
    # confidence intervals
    df$upper_ci <- fit + 1.96 * se_fit; df$lower_ci <- fit - 1.96 * se_fit
    df_bin <- aggregate(df, by = list(cut(as.matrix(df[, 2]), bins)), mean)
    # construct plot
    plot <- ggplot(data = df, aes(x = df[, 2], y = df[, 1]))
    plot <- plot + # linear fit
        geom_abline(slope = slope, intercept = intercept,
                    color = linfit_colour, size = linfit_width) +
        geom_point(data = df_bin, aes(x = df_bin[, 3], y = df_bin[, 2]),
                   color = cef_point_colour, size = cef_point_size) +
        # label slope
        labs(caption = paste0(" slope = ", signif(slope, 2), '\n SE:', se_type),
             x=xlabname, y=ylabname) +
        ylim(ylimit) + 
        xlim(xlimit) +
        theme_bw() +
        theme(plot.title = element_text(hjust = 0.5)) +
        labs(title=titletext)
    
    return(plot)
}
