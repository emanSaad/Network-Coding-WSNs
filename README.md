# Network-Coding-WSNs
## Select the best number and locations of encoding nodes by solving the mathematical model.

This code is an implementation for a mathematical model that is developed to determine the optimal number of encoding nodes, and their location, under certain failure scenarios. Besides reducing cost and improving reliability, sensor networks end up having a higher
performance in terms of delay because the overall number of network coding operations decreases; 


You can use different network sizes, I am using here 40 nodes network as shown bellow:

![NetGraph20Nodes](40NodesPlotResults.jpg)

This figure includes the maroon links to highlight a particular tree for data flow (for illustration), while green nodes highlight a particular set of gateways.
The failed links appear in the figure with yellow color, while the cyan links represent the alternative paths (constructed from encoding nodes).

For better understanding of this code,  please see the details of the mathematical model and its constraints in this [article](https://pdf.sciencedirectassets.com/272922/1-s2.0-S1570870519X00062/1-s2.0-S1570870518305511/main.pdf?X-Amz-Security-Token=IQoJb3JpZ2luX2VjEL%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIA6HAON401PQ9UiDrb1lkv7GTTkMXulfDIfrTltitHCdAiEA%2FdlxBFbFHHSG%2BSHRpss4BaANgwE3%2BvqIIEt%2B76GNFNwqvQMI%2BP%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARADGgwwNTkwMDM1NDY4NjUiDPbVdDwShVB9k2WRjCqRA5SEvsJXr37QodlG3LrxUAPi2lupGMxIfhr9bjTDrowtuz5Bl1CFrpebGIFDpISpRG7wFVuPFhpgaCsTa2kDj0TFtZgruJlvbGYYNQxxfVBDpBhRQ2p5KEBjVZ5D9c6lmcJH2e5f71Q8fqFLP6VbPUaQQuvFM8Y80M7xyi0oZNCnsuCbjB%2BGUjj1Exk5ppfMSvuAU%2FEpeBdVrByb2GlJu6b5qyHKkYHSvJxnccZYisnhb9vC%2BkMfP7RH4P5Ib3BAtdzqDNWBXe6HyR%2BpXHXQV%2FZuuv9M0N01CM0EAGJEbr4iiBid5r5W%2B98DV4OfJPu35g%2BS9GM%2FvdbwZh%2F3MvvWRPAX%2FhElJMbMzfpgNNMu5XHH9T5005rkRWheop9p1JzRca2MSZ9m1oHw6tLIz%2F3%2FPYeE5RLxrWvt4decvr5Q563pUmup2GA0b2U0X5UKhXtdjF2pOjiX3H4ocBUVLNtoecg8%2BHtfBaprBP7sGXjNJ1EPdquqtYce0PeH%2BKyz5ciL2DV7gY7cwexb2KfODWIOdRWwMMWo9IIGOusBvv24bQsFBE%2BEmZDaHQDcBywYXLxxeSzjIFg%2Fk5Tqa%2FgmcvrYLql%2B6IAz9%2BlkAS66St4z67vbXEFAqIsghEulpRYk8AgXoOWxBTebcQp1eZ9P%2Bk1wIXGr%2Bm0Kjz93Q3xz%2BcqICP1JbW4KDwWVdAzNeXHvrH8TN1j9BBFLyqUueOfo6XCxLxU124%2BnR6Qc243ag1ovkUKMTp2iTWqwe9ZLhBiD1cLJs6wmkX2Gpt3B%2BxMSE9bgSJh6x933h2l2Qd%2FBEepG6S6FxMqFGO%2BRCkv4afjHHGcGek%2B0H0SyzZemVUw9GUQqBzLq5KE%2F9w%3D%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20210325T225845Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=ASIAQ3PHCVTYYSTW3JXW%2F20210325%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=55aeae71ef97c0c01d937815f81399d13c3f8e2cc5296e020324659aa899be4e&hash=05bed75b8ff74f02325d10cfba0ea7d22e081d517b7eb90a59e90580337e6c88&host=68042c943591013ac2b2430a89b270f6af2c76d8dfd086a07176afe7c76c2c61&pii=S1570870518305511&tid=spdf-19092a6b-c29b-4dfe-a034-7b833e2eb63a&sid=2c97c3227c57e744492b41d8e1ee3345bd50gxrqb&type=client)
