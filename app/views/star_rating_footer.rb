class StarRatingFooter < UICollectionReusableView
  def initWithFrame(frame=[[0, 264], [44, 44]])
    super.tap do |footer|
      
      @the_view = UIView.alloc.initWithFrame([[50, 0], [220, 44]])
      @the_view.backgroundColor = UIColor.clearColor
      
      # create 4 labels
      labels = Array.new(4) do |idx|
        UILabel.alloc.init.tap do |label|
          label.translatesAutoresizingMaskIntoConstraints = false
          label.frame = CGRect.new([0, 0], CGSize.new(44.0, 44.0))
          label.text = "☆"
          label.textColor = UIColor.whiteColor
          label.font = UIFont.fontWithName("Heiti SC", size:30)
          label.textAlignment = NSTextAlignmentCenter
          label.backgroundColor = UIColor.clearColor
          @the_view.addSubview(label)
        end
      end
      
      footer.addSubview(@the_view)
      # create a Hash of with the label { "label0" => UILabel#instance, .... }
      views_dict = Hash[labels.map.with_index { |label, idx| ["label#{idx}", label] }]
      # we use autolayout to put them in row
      layout_rule = "H:|-[label0][label1(==label0)][label2(==label0)][label3(==label0)]-|"
      @the_view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(layout_rule, options:0, metrics:nil, views: views_dict))
    end
  end
  
end