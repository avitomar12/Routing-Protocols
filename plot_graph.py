import sys
import matplotlib.pyplot as plt

trace_file = sys.argv[1]

t_file = open(trace_file,'r')
t_file_content = t_file.read()

each_line = t_file_content.split('\n')

def plot_jitter(node_,type_,data_):
    _ = 0
    data = []
    plot_data = []
    for i in data_[:-1]:
        event = i.split(" ")[0]
        time = i.split(" ")[1]
        from_node = i.split(" ")[2]
        to_node = i.split(" ")[3]
        pkt_type = i.split(" ")[4]
        pkt_size = i.split(" ")[5]
        flags = i.split(" ")[6]
        fid = i.split(" ")[7]
        src_addr = i.split(" ")[8]
        dst_addr = i.split(" ")[9]
        seq_num = i.split(" ")[10]
        pkt_id = i.split(" ")[11]
        #print(to_node)
        #print(pkt_type)
        if (to_node == str(node_) and pkt_type == str(type_)):
            data.append(str(time))
        _+=1
    
    #prepare jitter data
    for _ in range(0,len(data)-1):
        plot_data.append(float(data[_+1]) - float(data[_]))
    
    #plot jitter
    plt.ylim((min(plot_data),max(plot_data)))
    plt.plot(plot_data[:200])
    plt.show()
