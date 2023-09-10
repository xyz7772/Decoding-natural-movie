function accuracy = mySVMdecoder(filex,unit_idx)
trainnum=1;
meanaccuracy=zeros(1,trainnum);
for train_i=1:trainnum %repeat training n times
    
% set random repeats
%separate data, 80% data as train set, 20% data as test set
size1=size(filex.act);
size2=size1(2); %repeat number
size3=size1(3); %frame number
temp_output=zeros(size3,size3);
n1=floor(0.8*size2);
n2=floor(0.2*size2);

%set random numbers for train sets and test sets
Repeat=[1:size2];
rng('shuffle');
random_num1 = Repeat(randperm(numel(Repeat),n1)); %random repeat index for training 
random_num2 = setdiff(Repeat, random_num1); %random repeat index for testing
        for i= 1:size3 
            for j=1:size3 
                if j~=i;
            %% define xtrain, ytrain, xtest, ytest
                xtrain1 = filex.act(unit_idx,random_num1,i);
                xtrain2 = filex.act(unit_idx,random_num1,j); %negative
                xtrain = [xtrain1,xtrain2]';
            
                ytrain= zeros(n1,1); %cell(n1,1);
                ytrain(1:n1)= i;
                ytrain(n1+1:2*n1)= j; 
                
                xtest1 = filex.act(unit_idx,random_num2,i);
                xtest2 = filex.act(unit_idx,random_num2,j); %negative
                xtest = [xtest1,xtest2]';
                
                ytest=zeros(n2,1); %cell(n2,1);
                ytest(1:n2)= i; 
                ytest(n2+1:2*n2)= j; 
        
        %% Train an SVM classifier using the processed data set
                SVMModel=fitcsvm(xtrain,ytrain);
        %% Predict
                result = predict(SVMModel, xtest);

                if length(result)~=length(ytest)
                    continue
                end
                accuracy = sum(result == ytest) / length(ytest) * 100;
                
                temp_output(i,j) = temp_output(i,j)+accuracy;
           
                else
                    temp_output(i,j)=nan;
                    continue
                end
            end
        end
temp_output_flat = temp_output(:);

meanaccuracy(train_i) = nanmean(temp_output_flat);
end
accuracy=mean(meanaccuracy);
fprintf('.');
end