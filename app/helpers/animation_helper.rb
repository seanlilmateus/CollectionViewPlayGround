module AnimationHelper
  class << self
    # Generates an image from the view (view must be opaque)
    def renderImageFromView(view)
      renderImageFromView(view, withRect:view.bounds)
    end
    
    
    def renderImageFromView(view, withRect:frame)
      # Create a new context of the desired size to render the image
  	  UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
  	  context = UIGraphicsGetCurrentContext()
	
  	  # Translate it, to the desired position
  	  CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y)
    
      # Render the view as image
      view.layer.renderInContext(context)
    
      # Fetch the image   
      rendered_image = UIGraphicsGetImageFromCurrentImageContext()
      # Cleanup
      UIGraphicsEndImageContext()
      rendered_image
    end
  
  
    def renderImageForAntialiasing(name)
      renderImageForAntialiasing(image, withInsets:UIEdgeInsetsMake(1, 1, 1, 1))
    end
    
    
    def renderImageForAntialiasing(image, withInsets:insets)
    	img_size_with_border = CGSize.new(image.size.width + insets.left + insets.right, image.size.height + insets.top + insets.bottom)
      
      # Create a new context of the desired size to render the image
    	UIGraphicsBeginImageContextWithOptions(img_size_with_border, UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero), 0)
      
      # The image starts off filled with clear pixels, so we don't need to explicitly fill them here
      image.drawInRect(CGRect.new([insets.left, insets.top], image.size))
      
      # Fetch the image
      rendered_image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      rendered_image
    end


    def renderImage(image, withMargin:width, color:color)
      AnimationHelper.renderImage(image, atSize:image.size, withMargin:width, color:color)
    end

    def renderImage(image, atSize:size, withMargin:marging, color:color)
      imageSizeWithBorder = CGSize.new(size.width + 2 * (marging + 1), size.height + 2 * (marging + 1))
      UIGraphicsBeginImageContextWithOptions(imageSizeWithBorder, false, 0)
      rect = CGRect.new([1, 1], [size.width + 2 * marging, size.height + 2 * marging])
      color.set
      UIRectFill(rect)
      image.drawInRect(CGRect.new([marging + 1, marging + 1], size))
      renderedImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      renderedImage
    end
  end
end