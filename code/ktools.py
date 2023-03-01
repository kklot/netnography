import numpy as np
import matplotlib.pyplot as plt
import matplotlib
import seaborn as sns
sns.set_context("paper")

def scan_cluser(m, n = [3, 6], cs = [100, 120], ms = [5,10]):
    """HBDScan and find predetermined number of clusters
    Parameter:
    ----------
    m : 
        embedding dimentions
    n : 
        min and max number of cluster to search
    cs : 
        cluster size min and max(min)
    ms : 
        min sample size min and max(min)
    """

    for i in range(cs[0], cs[1]+1):
        for j in range(ms[0], ms[1]):
            k = hdbscan.HDBSCAN(min_cluster_size = i, min_samples = j)
            k.fit(m)
            nc = k.labels_.max() + 1
            if (nc >= n[0] and nc <= n[1]):
                print(nc, n[0], n[1])
                plot_cluster(k, m, i, j)
    return 0

def plot_cluster(c, dim, cs, ms, save=False, name="fig", path = './'):
    """Plot cluster found with defined parameters

    Args:
        c (hdbscan): The clusterer from hdbscan
        dim (tsne): dimention generated with t-SNE
        cs (int): cluster size
        ms (itn): min sampling size
        save (bool, optional): save figure?. Defaults to False.
        name (str, optional): name of the figure. Defaults to "fig".
        path (str, optional): path to save. Defaults to './'.
    """

    nc = c.labels_.max()
    cpl = sns.hls_palette(nc+1)
    ccl = [cpl[x] if x >= 0 else (0.5, 0.5, 0.5) for x in c.labels_]
    cmcl = [sns.desaturate(x, p) for x, p in zip(ccl, c.probabilities_)]
    tt = str(nc)+" clusters, cluster size: "+str(cs)+", min samples: "+str(ms)
    plt.scatter(*dim.T, s=7, linewidth=0, c=cmcl, alpha=0.3)
    plt.title(tt)
    sns.despine()
    plt.show()
    if save:
        plt.savefig(path+name+str(cs)+str(ms)+'.png', dpi = 300, bbox_inches = 'tight')


def interpret(clusterer, dat, var = 'value', prompt = "", smp=20):
    """Interptet and summary a clustering result

    Args:
        clusterer (hdbscan): Results of HDBSCAN
        dat (pd): Pandas data frame
        var (str, optional): Variable containing text to summary. Defaults to 'value'.
        prompt (str, optional): Prompt for openAI. Defaults to "".
        smp (int, optional): Number of post to sample, weight with clustering probability. Defaults to 20.
    """

    if len(prompt) == 0:
        prompt = "What do the following messages have in common? Then further describe the main points in a maximum 10 sentences."
    n_clusters = clusterer.labels_.max()
    dat['cluster'] = clusterer.labels_
    dat['probs'] = clusterer.probabilities_
    for i in range(n_clusters+1):
        print(f"Cluster {i} Theme:", end=" ")
        too_long = True
        while (too_long):
            mess = "\n".join(dat[dat.cluster == i][var].sample(smp, weights=dat[dat.cluster == i].probs)
                .values)
            too_long = (len(mess.split())*(2048/1500) + 300) > 4097
        response = openai.Completion.create(
            engine="text-davinci-003",
            prompt=f'{prompt}\n\n"""\n{mess}\n"""\n\nTheme:',
            temperature=0, max_tokens=300, top_p=1, frequency_penalty=0, presence_penalty=0
        )
        print(response["choices"][0]["text"].replace("\n", ""))